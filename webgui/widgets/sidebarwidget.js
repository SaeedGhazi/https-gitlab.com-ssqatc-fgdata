define([
        'jquery', 'knockout', 'text!./sidebarwidget.html', 'jquery-ui/draggable',
], function(jquery, ko, htmlString) {

    function ViewModel(params) {
        var self = this;

        self.widget = ko.observable(params.widget);

        self.pinned = ko.observable(true);
        self.pin = function() {
            self.pinned(!self.pinned());
        }

        self.close = function() {
        }

        self.expanded = ko.observable(true);

        self.onMouseover = function() {
            self.expanded(true);
        }

        self.onMouseout = function() {
            if (!self.pinned())
                self.expanded(false);
        }
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
