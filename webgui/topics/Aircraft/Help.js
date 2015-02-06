define([
        'jquery', 'knockout', 'text!./Help.html'
], function(jquery, ko, htmlString) {
    function ViewModel(params) {
        var self = this;

        self.helpTitle = ko.observable("");
        self.helpText = ko.observableArray([]);

        jquery.get('/json/sim/help', null, function(data) {

            var helpText = [];
            data.children.forEach(function(prop) {
                if (prop.name === 'title') {
                    self.helpTitle(prop.value);
                } else if (prop.name == 'line') {
                    helpText.push(prop.value);
                }
            });
            self.helpText(helpText);

        });
    }

//    ViewModel.prototype.dispose = function() {
//    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
