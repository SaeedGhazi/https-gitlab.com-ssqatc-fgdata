define([
        'jquery', 'knockout', 'text!./Checklists.html','jquery-ui/accordion', 
], function(jquery, ko, htmlString) {
    function ViewModel(params) {
        var self = this;

        self.checklists = ko.observableArray([]);

        jquery.get('/json/sim/checklists?d=3', null, function(data) {

            var assembleChecklists = function(data) {

                var checklists = [];
                data.children.forEach(function(prop) {
                    if (prop.name === 'checklist') {
                        var checklist = {
                            title : 'unnamed',
                            items : []
                        };
                        checklists.push(checklist);
                        prop.children.forEach(function(prop) {
                            if (prop.name === 'title') {
                                checklist.title = prop.value;
                            } else if (prop.name == 'item') {
                                var item = {
                                    name : 'unnamed',
                                    value : 'empty'
                                }
                                checklist.items.push(item);
                                prop.children.forEach(function(prop) {
                                    if (prop.name === 'name') {
                                        item.name = prop.value;
                                    } else if (prop.name === 'value') {
                                        item.value = prop.value;
                                    }
                                });
                            }
                        });

                    }
                });
                return checklists;

            }

            self.checklists(assembleChecklists(data));
            jquery("#checklists").accordion({
              collapsible: true,
              heightStyle: "content",
              active: false,
            });
            jquery("#checklists li").hover(function() {
                $(this).addClass("ui-state-highlight").addClass("ui-corner-all");
                
            }, function() {
                $(this).removeClass("ui-state-highlight").removeClass("ui-corner-all");

            })
        });
    }

    ViewModel.prototype.dispose = function() {
    }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
