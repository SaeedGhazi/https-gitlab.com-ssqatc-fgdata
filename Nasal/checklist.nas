# Nasal functions for handling the checklists present under /sim/checklists

# Convert checklists into full tutorials.
var convert_checklists = func {

  var checklists = props.globals.getNode("/sim/checklists").getChildren("checklist");
  var tutorials = props.globals.getNode("/sim/tutorials");

  if (size(checklists)) {
    foreach (var ch; checklists) {
      var name = ch.getNode("title", 1).getValue();
      var tutorial = tutorials.getNode("tutorial[" ~ size(tutorials.getChildren("tutorial")) ~ "]", 1);

      # Initial high level config
      tutorial.getNode("name", 1).setValue("Checklist: " ~ name);
      var description = 
        "Tutorial to run through the " ~ 
        name ~ 
        " checklist.\n\nChecklist available through the Help->Checklists menu.\n\n";
        
      var step = tutorial.getNode("step", 1);
      step.getNode("message", 1).setValue("Checklist: " ~ name);    
        
      # Now go through each of the checklist items and generate a tutorial step 
      # for each.
      foreach (var item; ch.getChildren("item")) {
        step = tutorial.getNode("step["~ size(tutorial.getChildren("step")) ~ "]", 1);
        
        var msg = item.getNode("name", 1).getValue();
        
        if (size(item.getChildren("value")) > 0) {
          msg = msg ~ " :";
          foreach (var v; item.getChildren("value")) {
            msg = msg ~ " " ~ v.getValue();
          }
        }
              
        step.getNode("message", 1).setValue(msg);        
        description = description ~ msg ~ "\n";
        
        if (item.getNode("condition") != nil) {
          var cond = step.getNode("exit", 1).getNode("condition", 1);
          props.copy(item.getNode("condition", 1), cond);
        }      
      }
      
      tutorial.getNode("description", 1).setValue(description);    
    }
  }
}

_setlistener("/sim/signals/nasal-dir-initialized", func {
  convert_checklists();
});
