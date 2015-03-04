define([
        'knockout', 'text!./Aircraft.html', './SubtopicViewmodel'
], function(ko, htmlString, SubtopicViewmodel) {
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

    ko.components.register('Aircraft/Panel', {
        require : 'topics/Aircraft/Panel'
    });

    // Return component definition
    return {
        viewModel : {
            createViewModel : function(params, componentInfo) {
                return new SubtopicViewmodel([
                        'Help', 'Mass & Balance', 'Checklists', 'Failures', 'Panel', 'Select'
                ], "Aircraft", params);
            },
        },
        template : htmlString
    };
});
