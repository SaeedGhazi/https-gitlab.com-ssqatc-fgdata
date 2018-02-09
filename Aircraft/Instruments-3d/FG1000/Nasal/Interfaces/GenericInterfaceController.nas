# Generic Interface controller.

var nasal_dir = getprop("/sim/fg-root") ~ "/Aircraft/Instruments-3d/FG1000/Nasal/";
io.load_nasal(nasal_dir ~ 'Interfaces/PropertyPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/PropertyUpdater.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericEISPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericNavComPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericNavComUpdater.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/NavDataInterface.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericFMSPublisher.nas', "fg1000");
io.load_nasal(nasal_dir ~ 'Interfaces/GenericADCPublisher.nas', "fg1000");


var GenericInterfaceController = {

  _instance : nil,

  # Factory method
  getInstance : func() {
    if (GenericInterfaceController._instance == nil) {
      GenericInterfaceController._instance = GenericInterfaceController.new();
    }

    return GenericInterfaceController._instance;
  },

  new : func() {
    var obj = {
      parents : [GenericInterfaceController],
      running : 0,
    };

    obj.eisPublisher = fg1000.GenericEISPublisher.new();
    obj.navcomPublisher = fg1000.GenericNavComPublisher.new();
    obj.navcomUpdater = fg1000.GenericNavComUpdater.new();
    obj.navdataInterface = fg1000.NavDataInterface.new();
    obj.gpsPublisher = fg1000.GenericFMSPublisher.new();
    obj.adcPublisher = fg1000.GenericADCPublisher.new();
    return obj;
  },

  start : func() {
    if (me.running) return;
    me.eisPublisher.start();
    me.navcomPublisher.start();
    me.navcomUpdater.start();
    me.navdataInterface.start();
    me.gpsPublisher.start();
    me.adcPublisher.start();
  },

  stop : func() {
    if (me.running == 0) return;
    me.eisPublisher.stop();
    me.navcomPublisher.stop();
    me.navcomUpdater.stop();
    me.navdataInterface.stop();
    me.gpsPublisher.stop();
    me.adcPublisher.stop();
  },
};
