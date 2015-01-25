define([
        'knockout', 'jquery', 'leaflet'
], function(ko, jquery, leaflet) {

    function ViewModel(params, componentInfo) {
        var self = this;

        self.element = componentInfo.element;
        self.followAircraft = ko.observable(true);
        $(self.element).height($(self.element).width());

        self.map = leaflet.map(self.element).setView([
                53.5, 10.0
        ], 13);

        var osmLayer = new leaflet.TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom : 18,
            attribution : 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
        });
        self.map.addLayer(osmLayer);

        L.RotatedMarker = L.Marker.extend({
            options : {
                angle : 0
            },

            _setPos : function(pos) {
                L.Marker.prototype._setPos.call(this, pos);
                this._icon.style[L.DomUtil.TRANSFORM] += ' rotate(' + this.options.angle + 'deg)';
            }
        });

        var aircraftMarker = new L.RotatedMarker(self.map.getCenter(), {
            angle : 45,
            icon : L.icon({
                iconSize : [
                        60, 60
                ],
                iconAnchor : [
                        30, 30
                ],
                popupAncor : [
                        0, -32
                ],
                iconUrl : "images/aircraft.svg",
            }),
            zIndexOffset : 10000,
        });

        aircraftMarker.addTo(self.map);
        /*
         * aircraftMarker.setState = function(s) { var latlng = new
         * L.LatLng(s.lat, s.lon); aircraftMarker.options.angle = s.heading;
         * aircraftMarker.setLatLng(latlng); var label = "<p id='aircraft-label'>
         * heading:" + s.heading + "&deg; GS: " + s.speed + "kt</p>";
         * aircraftMarker.bindPopup(label); info.update(s); };
         */
        self.latitude = ko.observable(0).extend({
            fgprop : 'latitude'
        });

        self.longitude = ko.observable(0).extend({
            fgprop : 'longitude'
        });

        self.heading = ko.observable(0).extend({
            fgprop : 'heading'
        });

        self.position = ko.computed(function() {
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

        self.mapCenter = ko.computed(function() {
            return leaflet.latLng(self.latitude(), self.longitude());
        }).extend({
            rateLimit : 2000
        });

        self.mapCenter.subscribe(function(newValue) {
            if (self.followAircraft()) {
                self.map.setView(newValue);
            }
        });
    }

    // Return component definition
    return {
        viewModel : {
            createViewModel : function(params, componentInfo) {
                return new ViewModel(params, componentInfo);
            },
        },
        template : "&nbsp;", // no html required
    };
});
