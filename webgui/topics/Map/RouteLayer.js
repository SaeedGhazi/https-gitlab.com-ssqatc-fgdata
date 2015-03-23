(function(factory) {
    if (typeof define === "function" && define.amd) {
        // AMD. Register as an anonymous module.
        define([
                'leaflet', 'props', './MapIcons'
        ], factory);
    } else {
        // Browser globals
        factory();
    }
}(function(leaflet, SGPropertyNode, MAP_ICON) {

    leaflet.RouteLayer = leaflet.GeoJSON.extend({
        options : {
        /*
        pointToLayer : function(feature, latlng) {
            var options = {
                title : feature.properties.callsign,
                alt : feature.properties.callsign,
                riseOnHover : true,
            };

            if (feature.properties.type == "aircraft" || feature.properties.type == "multiplayer") {
                options.angle = feature.properties.heading;
                options.icon = MAP_ICON["aircraft"];
            }
            return new leaflet.RotatedMarker(latlng, options);
        },

        onEachFeature : function(feature, layer) {
            if (feature.properties) {
                var popupString = '<div class="popup">';
                for ( var k in feature.properties) {
                    var v = feature.properties[k];
                    popupString += k + ': ' + v + '<br />';
                }
                popupString += '</div>';
                layer.bindPopup(popupString, {
                    maxHeight : 200
                });
            }
        },

         */
        },
        onAdd : function(map) {
            leaflet.GeoJSON.prototype.onAdd.call(this, map);
            this.update(++this.updateId);
        },

        onRemove : function(map) {
            this.updateId++;
            leaflet.GeoJSON.prototype.onRemove.call(this, map);
        },

        stop : function() {
            this.updateId++;
        },

        updateId : 0,
        update : function(id) {
            var self = this;

            if (self.updateId != id)
                return;

            var url = "/json/autopilot/route-manager/route?d=3";
            var jqxhr = $.get(url).done(function(data) {
                self.clearLayers();
                self.addData(self.routePropsToGeoJson(data));
            }).fail(function(a, b) {
                self.updateId++;
                console.log(a, b);
                alert('failed to load RouteManager data');
            }).always(function() {
            });

            if (self.updateId == id) {
                setTimeout(function() {
                    self.update(id)
                }, 10000);
            }
        },

        routePropsToGeoJson : function(props) {
            var geoJSON = {
                type : "FeatureCollection",
                features : [],
            };
            var lineString = [];
            
            var root = new SGPropertyNode(props);
            root.getChildren("wp").forEach(function(wp) {
                var id = wp.getNode("id");
                var lon = wp.getNode("longitude-deg").getValue();
                var lat = wp.getNode("latitude-deg").getValue();
                
                var position = [ lon, lat ];
                lineString.push( position );

                geoJSON.features.push({
                    "type" : "Feature",
                    "geometry" : {
                        "type" : "Point",
                        "coordinates" : position,
                    },
                    "id" : id,
                    "properties" : {
                    },
                });
            });
            
            geoJSON.features.push({
                "type" : "LineString",
                "coordinates" : lineString,
            });
            
            if( lineString.length < 2 )
                return {}
            
            return geoJSON;
        },

    });

    leaflet.routeLayer = function(options) {
        return new leaflet.RouteLayer(null, options);
    }

}));