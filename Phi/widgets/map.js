define(
        [
                'knockout', 'jquery', 'leaflet', 'text!./map.html', 'text!../images/aircraft.svg'
        ],
        function(ko, jquery, leaflet, htmlString, aircraftSvg ) {

            function ViewModel(params, componentInfo) {
                var self = this;

                self.element = componentInfo.element;
                self.followAircraft = ko.observable(true);

                self.toggleFollowAircraft = function(a) {
                    self.followAircraft(!self.followAircraft());
                }

                self.altitude = ko.observable(0).extend({
                    fgprop : 'altitude'
                });

                self.tas = ko.observable(0).extend({
                    fgprop : 'groundspeed'
                });

                self.heading = ko.observable(0).extend({
                    fgprop : 'heading'
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
                    dragging: false,
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

                if( params && params.on ) {
                    for ( var p in params.on ) {
                        var h = params.on[p];
                        if( typeof(h) === 'function' )
                            self.map.on(p,h);
                    }
                }

                var baseLayers = {
                    "OpenStreetMaps" : new leaflet.TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        maxZoom : 18,
                        attribution : 'Map data &copy; <a target="_blank" href="http://openstreetmap.org">OpenStreetMap</a> contributors'
                    })
                }
                self.map.addLayer(baseLayers["OpenStreetMaps"]);

                if (params && params.hasFollowAircraft ) {
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

                if( params && params.selectedOverlays && params.overlays ) {
                    params.selectedOverlays.forEach(function(ovl) {
                        params.overlays[ovl].addTo(self.map);
                    });
                }

                if (params && params.scale) {
                  L.control.scale(params.scale).addTo(self.map);
                }

                L.RotatedMarker = L.Marker.extend({
                    options : {
                        angle : 0
                    },

                    _setPos : function(pos) {
                        L.Marker.prototype._setPos.call(this, pos);
                        this._icon.style[L.DomUtil.TRANSFORM] += ' rotate(' + this.options.angle + 'deg)';
                    }
                });

                L.AircraftMarker = L.RotatedMarker
                        .extend({
                            options : {
                                angle : 0,
                                clickable : false,
                                keyboard : false,
                                icon : L
                                        .divIcon({
                                            iconSize : [
                                                    60, 60
                                            ],
                                            iconAnchor : [
                                                    30, 30
                                            ],
                                            className : 'aircraft-marker-icon',
                                            html : aircraftSvg,
                                        }),
                                zIndexOffset : 10000,
                                updateInterval : 100,
                            },

                            initialize : function(latlng, options) {
                                L.RotatedMarker.prototype.initialize(latlng, options);
                                L.Util.setOptions(this, options);
                            },

                            onAdd : function(map) {
                                L.RotatedMarker.prototype.onAdd.call(this, map);
                                this.popup = L.popup({
                                    autoPan : false,
                                    keepInView : false,
                                    closeButton : false,
                                    className : 'aircraft-marker-popup',
                                    closeOnClick : false,
                                    maxWidth : 200,
                                    minWidth : 120,
                                    offset : [
                                            30, 30
                                    ],
                                }, this);
                                this.popup
                                        .setContent('<div class="aircraft-marker aircraft-marker-altitude"><span data-bind="text: altitude().toFixed(0)"></span>ft</div>'
                                                + '<div class="aircraft-marker aircraft-marker-heading"><span data-bind="text: heading().toFixed(0)"></span>&deg</div>'
                                                + '<div class="aircraft-marker aircraft-marker-tas"><span data-bind="text: tas().toFixed(0)"></span>kt</div><div style="clear: both"/>');
                                this.bindPopup(this.popup);
                                this.addTo(this._map);
                                this.openPopup();
                            },

                            onRemove : function(map) {
                                if (this.timeoutid != null)
                                    clearTimeout(this.timeoutid);
                                L.RotatedMarker.prototype.onRemove.call(this, map);
                            },

                        });

                L.aircraftMarker = function(latlng, options) {
                    return new L.AircraftMarker(latlng, options);
                }

                var aircraftMarker = L.aircraftMarker(self.map.getCenter());

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
                    aircraftMarker.setLatLng(newValue);
                });

                self.heading.subscribe(function(newValue) {
                    aircraftMarker.options.angle = newValue;
                });

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
                self.map.setView( center );
                aircraftMarker.options.angle = self.heading();
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
