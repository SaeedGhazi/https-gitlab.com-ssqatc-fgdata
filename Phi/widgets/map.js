define(
        [
                'knockout', 'jquery', 'leaflet', 'text!./map.html'
        ],
        function(ko, jquery, leaflet, htmlString) {

            if (!L.AircraftMarker) {
                L.AircraftMarker = L.Marker.extend({
                    options : {
                        draggable : true,
                        clickable : true,
                        keyboard : false,
                        zIndexOffset : 10000,
                    },

                    initialize : function(latlng, options) {
                        var extraIconClass = '';
                        if (options && options.className) {
                            extraIconClass = ' ' + options.className;
                        }
                        L.Marker.prototype.initialize(latlng, options);
                        L.Util.setOptions(this, options);
                        this.setIcon(L.divIcon({
                            iconSize : null,
                            className : 'aircraft-marker-icon' + extraIconClass,
                            html : '<div data-bind="component: { ' + 'name: \'AircraftMarker\', '
                                    + 'params: { rotate: heading, label: labelLines } ' + '}"></div>',
                        }));

                        this.isDragging = false;

                        this.on('dragstart', function(evt) {
                            evt.target.isDragging = true;
                        });

                        this.on('dragend', function(evt) {
                            var pos = evt.target.getLatLng();

                            var props = {
                                name : "position",
                                children : [
                                        {
                                            name : "latitude-deg",
                                            value : pos.lat,
                                        }, {
                                            name : "longitude-deg",
                                            value : pos.lng,
                                        },
                                ],
                            };
                            $.post("/json/", JSON.stringify(props));
                            evt.target.isDragging = false;
                        });
                    },

                });

                L.aircraftMarker = function(latlng, options) {
                    return new L.AircraftMarker(latlng, options);
                }
            }

            function ViewModel(params, componentInfo) {
                var self = this;

                self.element = componentInfo.element;
                self.followAircraft = ko.observable(true);

                self.toggleFollowAircraft = function(a) {
                    self.followAircraft(!self.followAircraft());
                    if (self.followAircraft()) {
                        self.map.setView(self.mapCenter());
                    }
                }

                self.altitude = ko.observable(0).extend({
                    fgprop : 'altitude'
                });

                self.tas = ko.observable(0).extend({
                    fgprop : 'groundspeed'
                });

                if (params && params.css) {
                    for ( var p in params.css) {
                        jquery(self.element).css(p, params.css[p]);
                    }
                }
                if (jquery(self.element).height() < 1) {
                    jquery(self.element).css("min-height", jquery(self.element).width());
                }

                var MapOptions = {
                    attributionControl : false,
                    dragging : false,
                };

                if (params && params.map) {
                    for ( var p in params.map) {
                        MapOptions[p] = params.map[p];
                    }
                    MapOptions = params.map;
                }

                self.map = leaflet.map(self.element, MapOptions).setView([
                        53.5, 10.0
                ], MapOptions.zoom || 13);

                if (params && params.on) {
                    for ( var p in params.on) {
                        var h = params.on[p];
                        if (typeof (h) === 'function')
                            self.map.on(p, h);
                    }
                }

                var baseLayers = {
                    "OpenStreetMaps" : new leaflet.TileLayer(
                            'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            {
                                maxZoom : 18,
                                attribution : 'Map data &copy; <a target="_blank" href="http://openstreetmap.org">OpenStreetMap</a> contributors'
                            })
                }
                self.map.addLayer(baseLayers["OpenStreetMaps"]);

                if (params && params.hasFollowAircraft) {
                    self.map.on('dragstart', function(e) {
                        self.followAircraft(false);
                    });

                    var followAircraftControl = L.control();

                    followAircraftControl.onAdd = function(map) {
                        this._div = L.DomUtil.create('div', 'followAircraft');
                        this._div.innerHTML = '<img src="images/followAircraft.svg" title="Center Map on Aircraft Position" data-bind="click: toggleFollowAircraft"/>';
                        return this._div;
                    }
                    followAircraftControl.addTo(self.map);
                }

                if (params && params.overlays) {
                    L.control.layers(baseLayers, params.overlays).addTo(self.map);
                }

                if (params && params.selectedOverlays && params.overlays) {
                    params.selectedOverlays.forEach(function(ovl) {
                        params.overlays[ovl].addTo(self.map);
                    });
                }

                if (params && params.scale) {
                    L.control.scale(params.scale).addTo(self.map);
                }

                var aircraftMarker = L.aircraftMarker(self.map.getCenter(), {
                    className : 'you-aircraft-marker-icon'
                });

                aircraftMarker.addTo(self.map);

                var aircraftTrack = L.polyline([], {
                    color : 'red'
                }).addTo(self.map);

                self.latitude = ko.observable(0).extend({
                    fgprop : 'latitude'
                });

                self.longitude = ko.observable(0).extend({
                    fgprop : 'longitude'
                });

                self.heading = ko.observable(0).extend({
                    fgprop : 'true-heading'
                });

                self.position = ko.pureComputed(function() {
                    return leaflet.latLng(self.latitude(), self.longitude());
                }).extend({
                    rateLimit : 200
                });

                self.position.subscribe(function(newValue) {
                    if (!aircraftMarker.isDragging)
                        aircraftMarker.setLatLng(newValue);
                });

                self.labelLines = [
                        'You', ko.pureComputed(function() {
                            var h = Math.round(self.heading());
                            var t = Math.round(self.tas());
                            var a = Math.round(self.altitude());
                            return '' + h + "T " + t + "KTAS " + a + "ft";
                        }),
                ];

                self.mapCenter = ko.pureComputed(function() {
                    return leaflet.latLng(self.latitude(), self.longitude());
                }).extend({
                    rateLimit : 2000
                });

                self.aircraftTrailLength = 60;

                self.mapCenter.subscribe(function(newValue) {
                    if (self.followAircraft()) {
                        self.map.setView(newValue);
                    }

                    var trail = aircraftTrack.getLatLngs();
                    while (trail.length > self.aircraftTrailLength)
                        trail.shift();
                    trail.push(newValue);
                    aircraftTrack.setLatLngs(trail);
                });

                var center = leaflet.latLng(self.latitude(), self.longitude());
                self.map.setView(center);
                aircraftMarker.setLatLng(center);
            }

            ViewModel.prototype.dispose = function() {
                this.map.remove();
            }

            // Return component definition
            return {
                viewModel : {
                    createViewModel : function(params, componentInfo) {
                        return new ViewModel(params, componentInfo);
                    },
                },
                template : htmlString,
            };
        });
