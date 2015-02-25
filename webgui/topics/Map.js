define([
        'knockout', 'text!./Map.html'
], function(ko, htmlString) {

    function ViewModel(params) {
        var self = this;

        var trackLayer = new L.GeoJSON(null, {});
        trackLayer.update = function(id) {
            var self = this;
            if (id != self.updateId)
                return;

            var url = "/flighthistory/track.json";

            var jqxhr = $.get(url).done(function(data) {
                self.clearLayers();
                self.addData(data);
            }).fail(function() {
                var r = confirm("Error loading flight history. Retry?");
                if (!r)
                    self.updateId++;
            }).always(function() {
            });

            setTimeout(function() {
                self.update(id)
            }, 10000);
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

            "dfs.de VFR" : new L.TileLayer(
                    'https://secais.dfs.de/static-maps/ICAO500-2014-DACH-Reprojected_01/tiles/{z}/{x}/{y}.png', {
                        minZoom : 5,
                        maxZoom : 15,
                        attribution : '&copy; <a target="_blank" href="http://www.dfs.de">DFS</a>',
                        bounds : L.latLngBounds(L.latLng(46.0, 5.0), L.latLng(55.1, 16.5)),
                    }),

            "Lower Airspace (Germany)" : new L.TileLayer('https://secais.dfs.de/static-maps/lower_20131114/tiles/{z}/{x}/{y}.png',
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

            "Clouds" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/clouds/{z}/{x}/{y}.png', {
                maxZoom : 14,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5,
                attribution : '&copy; <a target="_blank" href="http://openweathermap.org/">open weather map</a>',
            }),

            "Precipitation" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/precipitation/{z}/{x}/{y}.png', {
                maxZoom : 14,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5,
                attribution : '&copy; <a target="_blank" href="http://openweathermap.org/">open weather map</a>',
            }),

            "Isobares" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/pressure_cntr/{z}/{x}/{y}.png', {
                maxZoom : 7,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5,
                attribution : '&copy; <a target="_blank" href="http://openweathermap.org/">open weather map</a>',
            }),

            "Wind" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/wind/{z}/{x}/{y}.png', {
                maxZoom : 7,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5,
                attribution : '&copy; <a target="_blank" href="http://openweathermap.org/">open weather map</a>',
            }),
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
