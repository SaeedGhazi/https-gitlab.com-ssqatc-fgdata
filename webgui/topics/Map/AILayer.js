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

    leaflet.AILayer = leaflet.GeoJSON.extend({
        options : {
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

        },
        onAdd : function(map) {
            leaflet.GeoJSON.prototype.onAdd.call(this, map);
            this.update(++this.updateId);
        },

        onRemove : function(map) {
            this.updateId++;
            leaflet.GeoJSON.prototype.onRemove.call(this, map);
        },

        updateId : 0,
        update : function(id) {
            var self = this;

            if (self.updateId != id)
                return;

            var url = "/json/ai/models?d=99";
            var jqxhr = $.get(url).done(function(data) {
                self.clearLayers();
                self.addData(self.aiPropsToGeoJson(data, [
                        "aircraft", "multiplayer", "carrier"
                ]));
            }).fail(function(a, b) {
                self.updateId++;
                console.log(a, b);
                alert('failed to load AI data');
            }).always(function() {
            });

            if (self.updateId == id) {
                setTimeout(function() {
                    self.update(id)
                }, 10000);
            }
        },

        aiPropsToGeoJson : function(props, types) {
            var geoJSON = {
                type : "FeatureCollection",
                features : [],
            };

            var root = new SGPropertyNode(props);
            types.forEach(function(type) {
                root.getChildren(type).forEach(function(child) {

                    if (!child.getNode("valid").getValue())
                        return;

                    var position = child.getNode("position");
                    var orientation = child.getNode("orientation");
                    var velocities = child.getNode("velocities");
                    var lon = position.getNode("longitude-deg").getValue();
                    var lat = position.getNode("latitude-deg").getValue();
                    var alt = position.getNode("altitude-ft") * 0.3048;
                    var heading = orientation.getNode("true-heading-deg").getValue();
                    var id = child.getNode("id").getValue();
                    var callsign = "";
                    var name = "";
                    var speed = 0;
                    if (type == "multiplayer") {
                        name = child.getNode("sim").getNode("model").getNode("path").getValue();
                    }
                    if (type == "carrier") {
                        callsign = child.getNode("sign").getValue();
                        name = child.getNode("name").getValue();
                        speed = velocities.getNode("speed-kts").getValue();
                    } else {
                        callsign = child.getNode("callsign").getValue();
                        speed = velocities.getNode("true-airspeed-kt").getValue();
                    }

                    geoJSON.features.push({
                        "type" : "Feature",
                        "geometry" : {
                            "type" : "Point",
                            "coordinates" : [
                                    lon, lat, alt.toFixed(0)
                            ],
                        },
                        "id" : id,
                        "properties" : {
                            "type" : type,
                            "heading" : heading.toFixed(0),
                            "speed" : speed.toFixed(0),
                            "callsign" : callsign,
                            "name" : name,
                        },
                    });

                });
            });

            return geoJSON;
        },

    });

    leaflet.aiLayer = function(options) {
        return new leaflet.AILayer(null, options);
    }

}));
