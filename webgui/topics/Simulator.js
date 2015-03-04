define([
        'knockout', 'text!./Simulator.html'
], function(ko, htmlString) {
    ko.components.register('Simulator/Screenshot', {
        require : 'topics/Simulator/Screenshot'
    });

    ko.components.register('Simulator/Properties', {
        require : 'topics/Simulator/Properties'
    });

    ko.components.register('Simulator/Config', {
        require : 'topics/Simulator/Config'
    });

    ko.components.register('Simulator/Reset', {
        require : 'topics/Simulator/Reset'
    });

    ko.components.register('Simulator/Exit', {
        require : 'topics/Simulator/Exit'
    });

    function ViewModel(params) {
        var self = this;

        self.topics = [
                'Screenshot', 'Properties', 'Config', 'Reset', 'Exit'
        ];

        self.selectedTopic = ko.observable();

        self.selectedComponent = ko.pureComputed(function() {
            return "Simulator/" + self.selectedTopic();
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
