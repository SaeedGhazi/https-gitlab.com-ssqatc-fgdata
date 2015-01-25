define([
        'knockout', 'text!./radiostack.html'
], function(ko, htmlString) {

    function DualFrequencyViewModel(label, pfx) {
        var self = this;
        self.useKey = pfx + "use";
        self.sbyKey = pfx + "sby";

        self.label = ko.observable(label);
        self.use = ko.observable(188.888).extend({
            fgprop : self.useKey
        });
        
        self.stby = ko.observable(188.888).extend({
            fgprop : self.sbyKey
        });

        self.swap = function() {
            ko.utils.knockprops.write(self.useKey, this.stby());
            ko.utils.knockprops.write(self.sbyKey, this.use());
        };
    }

    function ViewModel(params) {
        this.radios = ko.observableArray([
                new DualFrequencyViewModel("COM1", "com1"), new DualFrequencyViewModel("COM2", "com2"),
                new DualFrequencyViewModel("NAV1", "nav1"), new DualFrequencyViewModel("NAV2", "nav2"),
        ]);

    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
