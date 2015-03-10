define([
        'jquery', 'knockout', 'text!./Config.html', 'fgcommand', 'kojqui/button', 'kojqui/buttonset'
], function(jquery, ko, htmlString,fgCommand ) {
    function ViewModel(params) {
        var self = this;

        self.aiEnabled = ko.observable().extend({ fgPropertyGetSet: "/sim/traffic-manager/enabled" });
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
