##
# Initialize addons configured with --addon=foobar command line switch:
# - get the list of registered add-ons
# - load the main.nas file of each add-on into namespace __addon[ADDON_ID]__
# - call function main() from every such main.nas with the add-on path as arg.

# Example:
#
# fgfs --addon=/foo/bar/baz
#
# - AddonManager.cxx parses /foo/bar/baz/addon-metadata.xml
# - AddonManager.cxx creates prop nodes under /addons containing add-on metadata
# - AddonManager.cxx loads /foo/bar/baz/config.xml into the Property Tree
# - AddonManager.cxx adds /foo/bar/baz to the list of aircraft paths (to get
#   permissions to read files from there)
# - this script loads /foo/bar/baz/main.nas into namespace __addon[ADDON_ID]__
# - this script calls main("/foo/bar/baz") from /foo/bar/baz/main.nas.
#
# For more details, see $FG_ROOT/Docs/README.add-ons.

var id = _setlistener("/sim/signals/fdm-initialized", func {
    removelistener(id);

    foreach (var addon; addons.registeredAddons()) {
      var main_nas = addon.basePath ~ "/main.nas";
      var namespace = "__addon" ~ "[" ~ addon.id ~ "]__";
      logprint(5, "Initializing addon '" ~ addon.name ~
                  "' version " ~ addon.version.str() ~ " from " ~ main_nas ~
                  " in " ~ namespace);
      io.load_nasal( main_nas, namespace );

      var addon_main = globals[namespace]["main"];
      var addon_main_args = [ addon.basePath ];
      call(addon_main, addon_main_args); #, object, namespace, error_vector);

      # Tell the world that the add-on is now loaded.
      addon.node.getChild("loaded", 0, 1).setBoolValue(1);
    }
})
