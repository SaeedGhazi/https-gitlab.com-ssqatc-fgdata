define([
        'jquery', 'knockout', 'text!./Help.html'
], function(jquery, ko, htmlString) {
    function ViewModel(params) {
        var self = this;

        self.helpTitle = ko.observable("");
        self.helpContent = ko.observableArray([]);

        jquery.get('/json/sim/help?d=2', null, function(data) {

            var helpContent = [];
            data.children.forEach(function(prop) {
                if (prop.name === 'title') {
                    self.helpTitle(prop.value);
                } else if (prop.name == 'line' ) {
                    helpContent.push({
                        type: 'line',
                        text: prop.value,
                    });
                } else if (prop.name == 'text') {
                    helpContent.push({
                        type: 'text',
                        text: prop.value,
                    });
                } else if (prop.name == 'key') {
                    var content = {
                            type: 'key',
                            name: 'noname',
                            desc: 'nothing',
                    }
                    helpContent.push(content);
                    prop.children.forEach(function(prop) {
                        if (prop.name === 'name') {
                            content.name = prop.value;
                        } else if( prop.name == 'desc' ) {
                            content.desc = prop.value;
                        }
                    });
                }
            });
            console.log(helpContent);
            self.helpContent(helpContent);

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
