define([
        'knockout', 'text!./Environment.html'
], function(ko, htmlString) {
    ko.components.register('Environment/Date & Time', {
        require : 'topics/Environment/DateTime'
    });

    ko.components.register('Environment/Weather', {
        require : 'topics/Environment/Weather'
    });

    ko.components.register('Environment/Position', {
        require : 'topics/Environment/Position'
    });

    function ViewModel(params) {
        var self = this;
        
        
        self.topics = [
                'Date & Time', 
                'Weather', 
                'Position',
        ];
        
        self.selectedTopic = ko.observable();
        
        self.selectedComponent = ko.pureComputed(function(){
            return "Environment/" + self.selectedTopic();
        });

        self.selectTopic = function(topic) {
            self.selectedTopic(topic);
        }

       self.selectTopic(self.topics[0]);

    }

    ViewModel.prototype.dispose = function() {
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
