define([
        'knockout', 'text!./Map.html'
], function(ko, htmlString) {

    function ViewModel(params) {
        var self = this;

        self.overlays = {
            "VFRMap.com Sectionals (US)" : new L.TileLayer('http://vfrmap.com/20140918/tiles/vfrc/{z}/{y}/{x}.jpg', {
                maxZoom : 12,
                minZoom : 3,
                attribution : '(c) <a href="VFRMap.com">VFRMap.com</a>',
                tms : true,
                opacity : 0.5,
                bounds : L.latLngBounds(L.latLng(16.0, -179.0), L.latLng(72.0, -60.0)),
            }),

            "VFRMap.com - Low IFR (US)" : new L.TileLayer('http://vfrmap.com/20140918/tiles/ifrlc/{z}/{y}/{x}.jpg', {
                maxZoom : 12,
                minZoom : 5,
                attribution : '© <a href="VFRMap.com">VFRMap.com</a>',
                tms : true,
                opacity : 0.5,
                bounds : L.latLngBounds(L.latLng(16.0, -179.0), L.latLng(72.0, -60.0)),
            }),

            "dfs.de VFR" : new L.TileLayer(
                    'https://secais.dfs.de/static-maps/ICAO500-2014-DACH-Reprojected_01/tiles/{z}/{x}/{y}.png', {
                        minZoom : 5,
                        maxZoom : 15,
                        attribution : 'Map data © <a href="http://www.dfs.de">DFS</a>',
                        bounds : L.latLngBounds(L.latLng(46.0, 5.0), L.latLng(55.1, 16.5)),
                    }),

            "Lower Airspace (Germany)" : new L.TileLayer('https://secais.dfs.de/static-maps/lower_20131114/tiles/{z}/{x}/{y}.png',
                    {
                        minZoom : 5,
                        maxZoom : 15,
                        attribution : 'Map data © <a href="http://www.dfs.de">DFS</a>',
                        bounds : L.latLngBounds(L.latLng(46.0, 5.0), L.latLng(55.1, 16.5)),
                    }),

            "France VFR" : new L.TileLayer('http://carte.f-aero.fr/oaci/{z}/{x}/{y}.png', {
                minZoom : 5,
                maxZoom : 15,
                attribution : 'Map data © <a href="http://carte.f-aero.fr/">F-AERO</a>',
                bounds : L.latLngBounds(L.latLng(41.0, -5.3), L.latLng(51.2, 10.1)),
            }),

            "France VAC Landing" : new L.TileLayer('http://carte.f-aero.fr/vac-atterrissage/{z}/{x}/{y}.png', {
                minZoom : 5,
                maxZoom : 15,
                attribution : 'Map data © <a href="http://carte.f-aero.fr/">F-AERO</a>',
                bounds : L.latLngBounds(L.latLng(41.0, -5.3), L.latLng(51.2, 10.1)),
            }),

            "France VAC Approach" : new L.TileLayer('http://carte.f-aero.fr/vac-approche/{z}/{x}/{y}.png', {
                minZoom : 5,
                maxZoom : 15,
                attribution : 'Map data © <a href="http://carte.f-aero.fr/">F-AERO</a>',
                bounds : L.latLngBounds(L.latLng(41.0, -5.3), L.latLng(51.2, 10.1)),
            }),

            "Precipitation" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/precipitation/{z}/{x}/{y}.png', {
                maxZoom : 14,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5
            }),

            "Isobares" : new L.TileLayer('http://{s}.tile.openweathermap.org/map/pressure_cntr/{z}/{x}/{y}.png', {
                maxZoom : 7,
                minZoom : 0,
                subdomains : '12',
                format : 'image/png',
                transparent : true,
                opacity : 0.5
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
