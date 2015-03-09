define([
        'knockout', 'text!./Map.html', './Map/NavdbLayer', './Map/AILayer'
], function(ko, htmlString, NavdbLayer ) {

    function ViewModel(params) {
        var self = this;

        var trackLayer = new L.GeoJSON(null, {});

        trackLayer.maxTrackPoints = 1000;

        trackLayer.track = {
            "type" : "Feature",
            "geometry" : {
                "type" : "LineString",
                "coordinates" : []
            },
            "properties" : {
                "type" : "FlightHistory",
                "last" : 0
            }
        }

        trackLayer.update = function(id) {
            var self = this;
            if (id != self.updateId)
                return;

            var url = "/flighthistory/track.json?count=" + self.maxTrackPoints + "&last=" + trackLayer.track.properties.last;

            var jqxhr = $.get(url).done(function(data) {
                self.clearLayers();
                Array.prototype.push.apply(trackLayer.track.geometry.coordinates, data.geometry.coordinates);
                if (data.properties) {
                    trackLayer.track.properties.last = data.properties.last || 0;
                }
                self.addData(trackLayer.track);

                // update fast until we have all points
                var updateDelay = data.geometry.coordinates.length < self.maxTrackPoints ? 120000 : 200;

                setTimeout(function() {
                    self.update(id)
                }, updateDelay);

            }).fail(function() {
                var r = confirm("Error loading flight history. Retry?");
                if (!r)
                    self.updateId++;
            }).always(function() {
            });

        }

        trackLayer.updateId = 0;
        trackLayer.start = function() {
            this.update(++this.updateId);
            return this;
        }

        trackLayer.stop = function() {
            ++this.updateId;
            return this;
        }

        trackLayer.onAdd = function(map) {
            this.start();
            return L.GeoJSON.prototype.onAdd.call(this, map);

        }

        trackLayer.onRemove = function(map) {
            this.stop();
            return L.GeoJSON.prototype.onRemove.call(this, map);
        }

        self.overlays = {
            "Track" : trackLayer,

            "NavDB": L.navdbLayer(),
            "AI": L.aiLayer(),

            "VFRMap.com Sectionals (US)" : new L.TileLayer('http://vfrmap.com/20140918/tiles/vfrc/{z}/{y}/{x}.jpg', {
                maxZoom : 12,
                minZoom : 3,
                attribution : '&copy; <a target="_blank" href="http://vfrmap.com">VFRMap.com</a>',
                tms : true,
                opacity : 0.5,
                bounds : L.latLngBounds(L.latLng(16.0, -179.0), L.latLng(72.0, -60.0)),
            }),

            "VFRMap.com - Low IFR (US)" : new L.TileLayer('http://vfrmap.com/20140918/tiles/ifrlc/{z}/{y}/{x}.jpg', {
                maxZoom : 12,
                minZoom : 5,
                attribution : '&copy; <a target="_blank" href="http://vfrmap.com">VFRMap.com</a>',
                tms : true,
                opacity : 0.5,
                bounds : L.latLngBounds(L.latLng(16.0, -179.0), L.latLng(72.0, -60.0)),
            }),

            "Germany VFR" : new L.TileLayer(
                    'https://secais.dfs.de/static-maps/ICAO500-2014-DACH-Reprojected_01/tiles/{z}/{x}/{y}.png', {
                        minZoom : 5,
                        maxZoom : 15,
                        attribution : '&copy; <a target="_blank" href="http://www.dfs.de">DFS</a>',
                        bounds : L.latLngBounds(L.latLng(46.0, 5.0), L.latLng(55.1, 16.5)),
                    }),

            "Germany Lower Airspace" : new L.TileLayer('https://secais.dfs.de/static-maps/lower_20131114/tiles/{z}/{x}/{y}.png',
                    {
                        minZoom : 5,
                        maxZoom : 15,
                        attribution : '&copy; <a target="_blank" href="http://www.dfs.de">DFS</a>',
                        bounds : L.latLngBounds(L.latLng(46.0, 5.0), L.latLng(55.1, 16.5)),
                    }),

            "France VFR" : new L.TileLayer('http://carte.f-aero.fr/oaci/{z}/{x}/{y}.png', {
                minZoom : 5,
                maxZoom : 15,
                attribution : '&copy; <a target="_blank" href="http://carte.f-aero.fr/">F-AERO</a>',
                bounds : L.latLngBounds(L.latLng(41.0, -5.3), L.latLng(51.2, 10.1)),
            }),

            "France VAC Landing" : new L.TileLayer('http://carte.f-aero.fr/vac-atterrissage/{z}/{x}/{y}.png', {
                minZoom : 5,
                maxZoom : 15,
                attribution : '&copy; <a target="_blank" href="http://carte.f-aero.fr/">F-AERO</a>',
                bounds : L.latLngBounds(L.latLng(41.0, -5.3), L.latLng(51.2, 10.1)),
            }),

            "France VAC Approach" : new L.TileLayer('http://carte.f-aero.fr/vac-approche/{z}/{x}/{y}.png', {
                minZoom : 5,
                maxZoom : 15,
                attribution : '&copy; <a target="_blank" href="http://carte.f-aero.fr/">F-AERO</a>',
                bounds : L.latLngBounds(L.latLng(41.0, -5.3), L.latLng(51.2, 10.1)),
            }),

            "OpenWeatherMap - Clouds" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/clouds/{z}/{x}/{y}.png', {
                maxZoom : 14,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5,
                attribution : '&copy; <a target="_blank" href="http://openweathermap.org/">open weather map</a>',
            }),

            "OpenWeatherMap - Precipitation" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/precipitation/{z}/{x}/{y}.png', {
                maxZoom : 14,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5,
                attribution : '&copy; <a target="_blank" href="http://openweathermap.org/">open weather map</a>',
            }),

            "OpenWeatherMap - Isobares" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/pressure_cntr/{z}/{x}/{y}.png', {
                maxZoom : 7,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5,
                attribution : '&copy; <a target="_blank" href="http://openweathermap.org/">open weather map</a>',
            }),

            "OpenWeatherMap - Wind" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/wind/{z}/{x}/{y}.png', {
                maxZoom : 7,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5,
                attribution : '&copy; <a target="_blank" href="http://openweathermap.org/">open weather map</a>',
            }),
        }
        self.mapResize = function(a,b) {
          self.overlays.NavDB.invalidate();
        }

        self.mapZoomend = function() {
          self.overlays.NavDB.invalidate();
        }

        self.mapMoveend = function() {
          self.overlays.NavDB.invalidate();
        }

    }

    ViewModel.prototype.dispose = function() {
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
