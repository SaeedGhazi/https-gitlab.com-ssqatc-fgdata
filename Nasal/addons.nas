##
# initialize addons configured with --addon=foobar command line switch
# - loop over /addons/addon[n] nodes
# - get root path in /addons/addon[n]/path property (set by options.cxx from --addon=/foo/bar)
# - load main.nas therein into namespace __addon[n]__
# - call function main() from that main.nas with addon-path as arg

# example:
# fgfs --addon=/foo/bar/baz
# options.cxx creates /addons/addon[0]/path=/foo/bar/baz
# options.cxx loads /foo/bar/baz/config.xml
# options.cxx add /foo/bar/baz to aircraft-dir (to get permissions to read files from there)
# this script loads /foo/bar/baz/main.nas into namespace __addon[0]__
# this script calls main("/foo/bar/baz") in /foo/bar/baz/main.nas0

_setlistener("/sim/signals/nasal-dir-initialized", func {
    foreach (var addon; props.globals.getNode("/addons").getChildren("addon")) {
      var main_nas = addon.getNode("path",1).getValue() ~ "/main.nas";
      var namespace = "__"  ~ addon.getName() ~ "[" ~ addon.getIndex() ~ "]__";
      printlog("alert","Initializing addon from " ~ main_nas ~ " in " ~ namespace );
      io.load_nasal( main_nas, namespace );
      var addon_main = globals[namespace]["main"];
      var addon_main_args = [ addon.getNode("path").getValue() ];
      call(addon_main, addon_main_args); #, object, namespace, error_vector);
    }
})

