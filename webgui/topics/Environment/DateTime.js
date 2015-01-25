define([
        'jquery', 'knockout', 'text!./DateTime.html', 'fgcommand', 'kojqui/datepicker', 'kojqui/spinner'
], function(jquery, ko, htmlString, fgcommand ) {
    function ViewModel(params) {
        var self = this;
        
        self.timesOfToday = [
                'Clock Time', 'Dawn', 'Morning', 'Noon', 'Afternoon', 'Dusk', 'Evening', 'Night',
        ];

        self.setTimeOfToday = function(type) {
            var offsetTypes = {
                    "Clock Time": "real",
                    "Dawn": "dawn",
                    "Morning": "morning",
                    "Noon": "noon",
                    "Afternoon": "afternoon",
                    "Dusk": "dusk",
                    "Evening": "evening",
                    "Night": "night",
            }
            offsetType = offsetTypes[type] || null;
            if( ! offsetType ) { 
                console.log("unknown time offset type ", type );
                return;
            }
            fgcommand.timeofday(offsetType);
        }

        self.wrapHour = function(evt, ui) {
           return self._wrap(evt,ui,0,23);
        }

        self.wrapMinute = function(evt, ui) {
            return self._wrap(evt,ui,0,59);
        }
        
        self._wrap = function(evt,ui,min,max) {
            if (ui.value > max) {
                $(evt.target).spinner("value", min);
                return false;
            } else if (ui.value < min) {
                $(evt.target).spinner("value", max);
                return false;
            }
        }

        self.gmtProp = ko.observable().extend({ fgprop: 'gmt' });
       
        self.simTimeUTC = ko.pureComputed( function() {
            return new Date(self.gmtProp() + "Z");
        });
        
       
        self.hour = ko.pureComputed({
            read: function() {
                return self.simTimeUTC().getHours();
            },
            write: function(newValue) {
                
            }
        });
        self.minute = ko.pureComputed({
            read: function() {
                return self.simTimeUTC().getMinutes();
            },
            write: function(newValue) {
                
            }
        });
        self.date = ko.observable(0);

    }

    ViewModel.prototype.dispose = function() {
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
