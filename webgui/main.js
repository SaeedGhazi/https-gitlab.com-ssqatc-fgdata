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
        fgcommand : 'lib/fgcommand',
    }
});

require([
        'knockout', 'jquery', 'themeswitch'
], function(ko, jquery) {

    function KnockProps(aliases) {

        var self = this;
        this.ws = new WebSocket('ws://' + location.host + '/PropertyListener');
        this.ws.onclose = function(ev) {
            var msg = 'Lost connection to FlightGear. Please reload this page and/or restart FlightGear.';
            alert(msg);
            throw new Error(msg);
        }

        this.ws.onerror = function(ev) {
            var msg = 'Error communicating with FlightGear. Please reload this page and/or restart FlightGear.';
            alert(msg);
            throw new Error(msg);
        }

        this.ws.onmessage = function(ev) {
            try {
                self.fire(JSON.parse(ev.data));
            } catch (e) {
            }
        };

        this.openCache = [];
        this.ws.onopen = function(ev) {
            // send subscriptions when the socket is open
            var c = self.openCache;
            delete self.openCache;
            c.forEach(function(e) {
                self.addListener(e.prop, e.koObservable);
            });
        }

        this.fire = function(json) {
            var koObservable = self.listeners[json.path] || null;
            if (!koObservable)
                return;
            koObservable(json.value);
        }

        this.listeners = {}

        this.addListener = function(prop, koObservable) {
            if (self.openCache) {
                // socket not yet open, just cache the request
                console.log("caching listener request");
                self.openCache.push({
                    "prop" : prop,
                    "koObservable" : koObservable
                });
                return;
            }

            var path = this.aliases[prop] || "";
            if (path.length == 0) {
                console.log("can't listen to " + prop + ": unknown alias.");
                return;
            }

            self.listeners[path] = koObservable;

            self.ws.send(JSON.stringify({
                command : 'addListener',
                node : path
            }));
            self.ws.send(JSON.stringify({
                command : 'get',
                node : path
            }));
        }

        this.aliases = aliases || {};
        this.setAliases = function(arg) {
            arg.forEach(function(a) {
                self.aliases[a[0]] = a[1];
            });
        }

        this.props = {};

        this.get = function(target, prop) {
            if (self.props[prop]) {
                return self.props[prop];
            }

            var p = (self.props[prop] = ko.pureComputed({
                read : target,
                write : function(newValue) {
                    if (newValue == target())
                        return;
                    target(newValue);
                    target.notifySubscribers(newValue);
                }
            }));

            self.addListener(prop, p);

            return p;
        }

        this.write = function(prop, value) {
            var path = this.aliases[prop] || "";
            if (path.length == 0) {
                console.log("can't write " + prop + ": unknown alias.");
                return;
            }
            this.ws.send(JSON.stringify({
                command : 'set',
                node : path,
                value : value
            }));
        }

        this.propsToObject = function(prop, map, result) {
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
                    "altitude", "/position/altitude-ft"
            ], [
                    "latitude", "/position/latitude-deg"
            ], [
                    "longitude", "/position/longitude-deg"
            ], [
                    "airspeed", "/velocities/airspeed-kt"
            ], [
                    "slip", "/instrumentation/slip-skid-ball/indicated-slip-skid"
            ], [
                    "cg", "/fdm/jsbsim/inertia/cg-x-in"
            ], [
                    "weight", "/fdm/jsbsim/inertia/weight-lbs"
            ],
            // radio settings
            [
                    "com1use", "/instrumentation/comm/frequencies/selected-mhz"
            ], [
                    "com1sby", "/instrumentation/comm/frequencies/standby-mhz"
            ], [
                    "com1stn", "/instrumentation/comm/station-name"
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
                    "metar", "/environment/metar/data"
            ], [
                    "metar-valid", "/environment/metar/valid"
            ],
    ]);

    function PhiViewModel(props) {
        var self = this;
        self.props = props;
        self.widgets = ko.observableArray([
                "efis", "radiostack", "map"
        ]);

        self.topics = [
                'Aircraft', 'Environment', 'Map', 'Tools', 'Simulator', 'Help',
        ];

        self.selectedTopic = ko.observable();

        self.selectTopic = function(topic) {
            self.selectedTopic(topic);
        }

        self.selectTopic(self.topics[0]);
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

    ko.components.register('map', {
        require : 'widgets/map'
    });

    ko.components.register('radiostack', {
        require : 'widgets/radiostack'
    });

    ko.components.register('efis', {
        require : 'widgets/efis'
    });

    ko.applyBindings(new PhiViewModel());

});
