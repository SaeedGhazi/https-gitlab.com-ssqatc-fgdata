define([
        'knockout', 'text!./Aircraft.html', 
], function(ko, htmlString) {
    ko.components.register('Aircraft/Select', {
        require : 'topics/Aircraft/Select'
    });

    ko.components.register('Aircraft/Mass & Balance', {
        require : 'topics/Aircraft/MassBalance'
    });

    ko.components.register('Aircraft/Checklists', {
        require : 'topics/Aircraft/Checklists'
    });

    ko.components.register('Aircraft/Help', {
        require : 'topics/Aircraft/Help'
    });

    function ViewModel(params) {
        var self = this;
        
        self.topics = [
                'Select', 'Mass & Balance', 'Checklists', 'Failures', 'Panel', 'Help'
        ];
        
        self.selectedTopic = ko.observable();
        
        self.selectedComponent = ko.pureComputed(function(){
            return "Aircraft/" + self.selectedTopic();
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
