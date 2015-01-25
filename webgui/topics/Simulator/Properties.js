define([
        'jquery', 'knockout', 'text!./Properties.html', 
], function(jquery, ko, htmlString) {
    function PropertyViewModel() {
        var self = this;
        self.name = ko.observable('');
        self.value = ko.observable('');
        self.children = ko.observableArray([]);
    }
    
    function ViewModel(params) {
        var self = this;

        var properties = ko.observableArray([]);
    }

    ViewModel.prototype.dispose = function() {
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
