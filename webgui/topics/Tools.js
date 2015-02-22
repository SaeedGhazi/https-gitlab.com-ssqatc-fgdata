define([
        'knockout', 'text!./Tools.html'
], function(ko, htmlString) {

    ko.components.register('Tools/Holding Pattern', {
        require : 'topics/Tools/Holding'
    });

    ko.components.register('Tools/Vertical Navigation', {
        require : 'topics/Tools/VerticalNavigation'
    });

    ko.components.register('Tools/Stopwatch', {
        require : 'topics/Tools/Stopwatch'
    });

    function ViewModel(params) {
        var self = this;

        self.topics = [
                'Holding Pattern', 
                'Wind Calculator', 
                'Vertical Navigation',
                'Stopwatch'
        ];

        self.selectedTopic = ko.observable();

        self.selectedComponent = ko.pureComputed(function() {
            return "Tools/" + self.selectedTopic();
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
