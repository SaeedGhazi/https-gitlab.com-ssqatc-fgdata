define([
        'jquery', 'knockout', 'text!./Properties.html',
], function(jquery, ko, htmlString) {

    function PropertyViewModel() {
        var self = this;

        function load() {
            jquery.get('/json' + self.path, null, function(data) {
                self.hasChildren = data.nChildren > 0;
                if (typeof (data.value) != 'undefined') {
                    self.value(data.value);
                    self.hasValue = true;
                } else {
                    self.value('');
                    self.hasValue = false;
                }

                var a = [];
                if (data.children) {
                    data.children.forEach(function(prop) {
                        var p = new PropertyViewModel();
                        p.name = prop.name;
                        p.path = prop.path;
                        p.hasChildren = prop.nChildren > 0;
                        if (typeof (prop.value) != 'undefined') {
                            p.value(prop.value);
                            p.hasValue = true;
                        } else {
                            p.hasValue = false;
                        }
                        a.push(p);
                    });
                    self.children(a.sort(function(a, b) {
                        if (a.name == b.name) {
                            return a.index - b.index;
                        }
                        return a.name.localeCompare(b.name);
                    }));
                }

            });
        }
        self.name = '';
        self.value = ko.observable('');
        self.children = ko.observableArray([]);
        self.index = 0;
        self.path = '';
        self.hasChildren = false;
        self.hasValue = false;

        self.isExpanded = ko.observable(false);
        self.isExpanded.subscribe(function(newValue) {
            if (newValue) {
                load();
            } else {
                self.children.removeAll();
            }
        });

        self.toggle = function() {
            if (self.hasChildren) {
                self.isExpanded(!self.isExpanded());
            } else {
                load();
            }
        }

        self.valueEdit = function(prop, evt) {
            var inplaceEditor = jquery(jquery('#inplace-editor-template').html());

            var elem = jquery(evt.target);
            elem.hide();
            elem.after(inplaceEditor);
            inplaceEditor.val(elem.text());
            inplaceEditor.focus();

            function endEdit(val) {
                inplaceEditor.remove();
                elem.show();

                if (typeof (val) === 'undefined')
                    return;
                var val = val.trim();
                elem.text(val);

                jquery.post('/json' + self.path, JSON.stringify({
                    value : val
                }));
            }

            inplaceEditor.on('keyup', function(evt) {
                switch (evt.keyCode) {
                case 27:
                    endEdit();
                    break;
                case 13:
                    endEdit(inplaceEditor.val());
                    break;
                }
            });

            inplaceEditor.blur(function() {
                endEdit(inplaceEditor.val());
            });
        }
    }

    function ViewModel(params) {
        var self = this;

        self.root = new PropertyViewModel();
        self.root.name = "root";
        self.root.path = "/";
        self.root.isExpanded(true);
        self.properties = self.root.children;
    }

    // ViewModel.prototype.dispose = function() {
    // }

    // Return component definition
    return {
        viewModel : ViewModel,
        template : htmlString
    };
});
