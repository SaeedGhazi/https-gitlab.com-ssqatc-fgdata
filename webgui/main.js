require.config({
    baseUrl : '.',
    paths : {
        jquery : '3rdparty/jquery/jquery-1.11.2.min',
        'jquery-ui' : '3rdparty/jquery/ui',
        knockout : '3rdparty/knockout/knockout-3.2.0',
        kojqui : '3rdparty/knockout-jqueryui',
        sprintf : '3rdparty/sprintf/sprintf.min',
        leaflet : '3rdparty/leaflet-0.7.3/leaflet',
        text : '3rdparty/require/text',
        flot : '3rdparty/flot/jquery.flot',
        flotresize : '3rdparty/flot/jquery.flot.resize',
        flottime : '3rdparty/flot/jquery.flot.time',
        fgcommand : 'lib/fgcommand',
        props : 'lib/props2',
        sammy: '3rdparty/sammy-latest.min',
        aircraft: '../aircraft-dir',
        pagedown: '3rdparty/pagedown'
    }
});

require([
        'knockout', 'jquery','sammy', 'fgcommand', 'themeswitch', 'kojqui/button', 'kojqui/buttonset', 'kojqui/selectmenu', 'jquery-ui/sortable', 'flot', 'leaflet'
], function(ko, jquery, Sammy, fgcommand ) {

    function KnockProps(aliases) {

        var self = this;

        self.initWebsocket = function() {
            self.ws = new WebSocket('ws://' + location.host + '/PropertyListener');

            self.ws.onclose = function(ev) {
                var msg = 'Lost connection to FlightGear. Should I try to reconnect?';
                if (confirm(msg)) {
                    // try reconnect
                    self.initWebsocket();
                } else {
                    throw new Error(msg);
                }
            }

            self.ws.onerror = function(ev) {
                var msg = 'Error communicating with FlightGear. Please reload this page and/or restart FlightGear.';
                alert(msg);
                throw new Error(msg);
            }

            self.ws.onmessage = function(ev) {
                try {
                    self.fire(JSON.parse(ev.data));
                } catch (e) {
                }
            };

            self.openCache = [];
            self.ws.onopen = function(ev) {
                // send subscriptions when the socket is open
                var c = self.openCache;
                delete self.openCache;
                c.forEach(function(e) {
                    self.addListener(e.prop, e.koObservable);
                });
                for ( var p in self.listeners) {
                    self.addListener(p, self.listeners[p]);
                }
            }

        }

        self.initWebsocket();

        self.fire = function(json) {
            var value = json.value;
            var listeners = self.listeners[json.path] || [];
            listeners.forEach(function(koObservable) {
                koObservable(value)
            });
            koObservable(json.value);
        }

        function resolvePropertyPath(self, pathOrAlias) {
            if (pathOrAlias in self.aliases)
                return self.aliases[pathOrAlias];
            if (pathOrAlias.charAt(0) == '/')
                return pathOrAlias;
            return null;
        }

        self.listeners = {}

        self.removeListener = function(pathOrAlias, koObservable) {
            var path = resolvePropertyPath(self, pathOrAlias);
            if (path == null) {
                console.log("can't remove listener for " + pathOrAlias + ": unknown alias or invalid path.");
                return self;
            }

            var listeners = self.listeners[path] || [];
            var idx = listeners.indexOf(koObservable);
            if (idx == -1) {
                console.log("can't remove listener for " + path + ": not a listener.");
                return self;
            }

            listeners.splice(idx, 1);

            if (0 == listeners.length) {
                self.ws.send(JSON.stringify({
                    command : 'removeListener',
                    node : path
                }));
            }

            return self;
        }

        self.addListener = function(alias, koObservable) {
            if (self.openCache) {
                // socket not yet open, just cache the request
                self.openCache.push({
                    "prop" : alias,
                    "koObservable" : koObservable
                });
                return self;
            }

            var path = resolvePropertyPath(self, alias);
            if (path == null) {
                console.log("can't listen to " + alias + ": unknown alias or invalid path.");
                return self;
            }

            var listeners = self.listeners[path] = (self.listeners[path] || []);
            if (listeners.indexOf(koObservable) != -1) {
                console.log("won't listen to " + path + ": duplicate.");
                return self;
            }

            koObservable.fgPropertyPath = path;
            koObservable.fgBaseDispose = koObservable.dispose;
            koObservable.dispose = function() {
                if( this.fgPropertyPath ) {
                    self.removeListener( this.fgPropertyPath, this );
                }
                this.fgBaseDispose.call(this);
            }
            listeners.push(koObservable);
            koObservable.fgSetPropertyValue = function(value) {
                self.setPropertyValue( this.fgPropertyPath, value );
            }

            if (1 == listeners.length) {
                self.ws.send(JSON.stringify({
                    command : 'addListener',
                    node : path
                }));
            }
            self.ws.send(JSON.stringify({
                command : 'get',
                node : path
            }));

            return self;
        }

        self.aliases = aliases || {};
        self.setAliases = function(arg) {
            arg.forEach(function(a) {
                self.aliases[a[0]] = a[1];
            });
        }

        self.props = {};

        self.get = function(target, prop) {
            if (self.props[prop]) {
                return self.props[prop];
            }

            return (self.props[prop] = self.observedProperty( target, prop )); 
        }
        
        self.observedProperty = function( target, prop ) {
            var reply = ko.pureComputed({
                read: target,
                write: function(newValue) {
                    if( newValue == target() )
                        return;
                    target(newValue);
                    target.notifySubscribers(newValue);
                }
            });
            self.addListener(prop, reply);
            return reply;
        }

        self.write = function(prop, value) {
            var path = this.aliases[prop] || "";
            if (path.length == 0) {
                console.log("can't write " + prop + ": unknown alias.");
                return;
            }

            self.setPropertyValue(path,value);
        }

        self.setPropertyValue = function(path, value) {
            this.ws.send(JSON.stringify({
                command : 'set',
                node : path,
                value : value
            }));
        }

        self.propsToObject = function(prop, map, result) {
            result = result || {}
            prop.children.forEach(function(prop) {
                var target = map[prop.name] || null;
                if (target) {
                    if (typeof (result[target]) === 'function') {
                        result[target](prop.value);
                    } else {
                        result[target] = prop.value;
                    }
                }
            });
            return result;
        }
    }

    ko.extenders.fgprop = function(target, prop) {
        return ko.utils.knockprops.get(target, prop);
    };
    
    ko.extenders.observedProperty = function(target,prop) {
        return ko.utils.knockprops.observedProperty(target,prop);
    };

    ko.extenders.fgPropertyGetSet = function(target,option) {

        fgCommand.getPropertyValue(option, function(value) {
          target(value);
        }, self);

        var p = ko.pureComputed({
            read : target,
            write : function(newValue) {
                if (newValue == target())
                    return;
                target(newValue);
                target.notifySubscribers(newValue);
                fgCommand.setPropertyValue(option, newValue );
            }
        });
        return p;
    }


    ko.utils.knockprops = new KnockProps();

    ko.utils.knockprops.setAliases([
            // time
            [
                    "gmt", "/sim/time/gmt"
            ], [
                    "local-offset", "/sim/time/local-offset"
            ],

            // flight
            [
                    "pitch", "/orientation/pitch-deg"
            ], [
                    "roll", "/orientation/roll-deg"
            ], [
                    "heading", "/orientation/heading-magnetic-deg"
            ], [
                    "true-heading", "/orientation/heading-deg"
            ], [
                    "altitude", "/position/altitude-ft"
            ], [
                    "latitude", "/position/latitude-deg"
            ], [
                    "longitude", "/position/longitude-deg"
            ], [
                    "airspeed", "/velocities/airspeed-kt"
            ], [
                    "groundspeed", "/velocities/groundspeed-kt"
            ], [
                    "slip", "/instrumentation/slip-skid-ball/indicated-slip-skid"
            ], [
                    "cg", "/fdm/jsbsim/inertia/cg-x-in"
            ], [
                    "weight", "/fdm/jsbsim/inertia/weight-lbs"
            ],
            // radio settings
            [
                    "com1stn", "/instrumentation/comm/station-name"
            ], [
                    "com1use", "/instrumentation/comm/frequencies/selected-mhz"
            ], [
                    "com1sby", "/instrumentation/comm/frequencies/standby-mhz"
            ], [
                    "com1stn", "/instrumentation/comm/station-name"
            ], [
                    "com2stn", "/instrumentation/comm[1]/station-name"
            ], [
                    "com2use", "/instrumentation/comm[1]/frequencies/selected-mhz"
            ], [
                    "com2sby", "/instrumentation/comm[1]/frequencies/standby-mhz"
            ], [
                    "com2stn", "/instrumentation/comm[1]/station-name"
            ], [
                    "nav1use", "/instrumentation/nav/frequencies/selected-mhz"
            ], [
                    "nav1sby", "/instrumentation/nav/frequencies/standby-mhz"
            ], [
                    "nav1stn", "/instrumentation/nav/nav-id"
            ], [
                    "nav2use", "/instrumentation/nav[1]/frequencies/selected-mhz"
            ], [
                    "nav2sby", "/instrumentation/nav[1]/frequencies/standby-mhz"
            ], [
                    "nav2stn", "/instrumentation/nav[1]/nav-id"
            ], [
                    "adf1use", "/instrumentation/adf/frequencies/selected-khz"
            ], [
                    "adf1sby", "/instrumentation/adf/frequencies/standby-khz"
            ], [
                    "adf1stn", "/instrumentation/adf/ident"
            ], [
                    "dme1use", "/instrumentation/dme/frequencies/selected-mhz"
            ], [
                    "dme1dst", "/instrumentation/dme/indicated-distance-nm"
            ], [
                    "xpdrcod", "/instrumentation/transponder/id-code"
            ],
            // weather
            [
                    "ac-wdir", "/environment/wind-from-heading-deg"
            ], [
                    "ac-wspd", "/environment/wind-speed-kt"
            ], [
                    "ac-visi", "/environment/visibility-m"
            ], [
                    "ac-temp", "/environment/temperature-degc"
            ], [
                    "ac-dewp", "/environment/dewpoint-degc"
            ], [
                    "gnd-wdir", "/environment/config/boundary/entry/wind-from-heading-deg"
            ], [
                    "gnd-wspd", "/environment/config/boundary/entry/wind-speed-kt"
            ], [
                    "gnd-visi", "/environment/config/boundary/entry/visibility-m"
            ], [
                    "gnd-temp", "/environment/config/boundary/entry/temperature-degc"
            ], [
                    "gnd-dewp", "/environment/config/boundary/entry/dewpoint-degc"
            ], [
                    "metar-valid", "/environment/metar/valid"
            ],
    ]);

    function PhiViewModel(props) {
        var self = this;
        self.props = props;
        self.widgets = ko.observableArray([
                "METAR", "PFD", "Radiostack", "Small Map", "Stopwatch"
        ]);

        self.topics = [
                'Aircraft', 'Environment', 'Map', 'Tools', 'Simulator', 'Help',
        ];

        self.selectedTopic = ko.observable();
        self.selectedSubtopic = ko.observable();

        self.selectTopic = function(topic) {
            location.hash = topic;
        }

        self.refresh = function() {
            location.reload();
        }

        self.doPause = function() {
            fgcommand.pause();
        }

        self.doUnpause = function() {
            fgcommand.unpause();
        }

        jquery("#widgetarea").sortable({
            handle: ".widget-handle",
            axis: "y",
            cursor: "move",
        });
        jquery("#widgetarea").disableSelection();

        // Client-side routes
        Sammy(function() {
            this.get('#:topic', function() {
                self.selectedTopic( this.params.topic );
                self.selectedSubtopic('');
            });

            this.get('#:topic/:subtopic', function() {
                self.selectedTopic( this.params.topic );
                self.selectedSubtopic( this.params.subtopic );
            });
            // empty route
            this.get('', function() {
                this.app.runRoute( 'get', '#' + self.topics[0] );
            });
        }).run();

    }

    ko.components.register('Aircraft', {
        require : 'topics/Aircraft'
    });

    ko.components.register('Environment', {
        require : 'topics/Environment'
    });

    ko.components.register('Map', {
        require : 'topics/Map'
    });

    ko.components.register('Tools', {
        require : 'topics/Tools'
    });

    ko.components.register('Simulator', {
        require : 'topics/Simulator'
    });

    ko.components.register('Help', {
        require : 'topics/Help'
    });

    ko.components.register('sidebarwidget', {
        require : 'widgets/sidebarwidget'
    });

    ko.components.register('Small Map', {
        require : 'widgets/map'
    });

    ko.components.register('Radiostack', {
        require : 'widgets/radiostack'
    });

    ko.components.register('METAR', {
        require : 'widgets/metar'
    });

    ko.components.register('PFD', {
        require : 'widgets/efis'
    });

    ko.components.register('Stopwatch', {
        require : 'widgets/Stopwatch'
    });
    
    ko.components.register('dualarcgauge', {
        require: 'instruments/DualArcGauge'
    })

    ko.bindingHandlers.flotchart = {
        init : function(element, valueAccessor, allBindings) {
            // This will be called when the binding is first applied to an
            // element
            // Set up any initial state, event handlers, etc. here
            var value = valueAccessor() || {};

            if (value.hover && typeof (value.hover) === 'function') {
                $(element).bind("plothover", function(event, pos, item) {
                    value.hover(pos, item);
                });
            }
        },

        update : function(element, valueAccessor, allBindings) {
            var value = valueAccessor() || {};
            var data = ko.unwrap(value.data);
            var options = ko.unwrap(value.options);
            jquery.plot(element, data, options);

        },

    };

    ko.applyBindings(new PhiViewModel(),document.getElementById('wrapper'));

});
