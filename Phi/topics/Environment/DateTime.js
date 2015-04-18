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
           return self._wrap(evt,ui,0,24);
        }

        self.wrapMinute = function(evt, ui) {
            return self._wrap(evt,ui,0,60);
        }
        
        self._wrap = function(evt,ui,min,max) {
            if (ui.value >= max) {
                $(evt.target).spinner("value", ui.value - max);
                return false;
            } else if (ui.value < min) {
                $(evt.target).spinner("value", ui.value + max);
                return false;
            }
            $(evt.target).spinner("value",ui.value);
            return true;
        }

        self.gmtProp = ko.observable().extend({ fgprop: 'gmt' });
       
        self.simTimeUTC = ko.pureComputed({
            read: function() {
                return new Date(self.gmtProp() + "Z");
            },
            write: function(newValue) {
                console.log("new time: ", newValue );
            }
        });
        
       
        self.hour = ko.pureComputed({
            read: function() {
                return self.simTimeUTC().getUTCHours();
            },
            write: function(newValue) {
                console.log("new hour", newValue );
            }
        });
        self.minute = ko.pureComputed({
            read: function() {
                return self.simTimeUTC().getUTCMinutes();
            },
            write: function(newValue) {
                console.log("new minute", newValue );
            }
        });
    }

    ViewModel.prototype.dispose = function() {
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
