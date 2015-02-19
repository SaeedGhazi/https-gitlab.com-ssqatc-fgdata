define([
        'jquery', 'knockout', 'text!./Stopwatch.html', 'kojqui/button'
], function(jquery, ko, htmlString) {

    function ViewModel(params) {
        var self = this;
        
        self.watches = ko.observableArray([0]);
        
        self.addWatch = function() {
            self.watches.push(self.watches().length);
        }
    }

     ViewModel.prototype.dispose = function() {
     }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
