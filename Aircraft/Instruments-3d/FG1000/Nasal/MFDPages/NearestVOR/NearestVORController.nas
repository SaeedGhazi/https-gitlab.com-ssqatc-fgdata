# NearestVOR Controller
var NearestVORController =
{

  UIGROUP : {
    NONE : 0, # No group currently selected,
    VOR  : 1,
    FREQ : 2,
  },

  new : func (page, svg)
  {
    var obj = { parents : [ NearestVORController, MFDPageController.new(page) ] };

    obj.page = page;
    obj._currentGroup = NearestVORController.UIGROUP.NONE;
    obj._crsrToggle = 0;

    return obj;
  },

  selectVOR : func() {
    me.selectGroup(NearestVORController.UIGROUP.VOR)
  },
  selectFrequencies : func() {
    me.selectGroup(NearestVORController.UIGROUP.FREQ);
  },
  getSelectedGroup : func() {
    return me._currentGroup;
  },
  selectGroup : func(grp) {
    me._currentGroup = grp;
    if (grp == NearestVORController.UIGROUP.VOR)  me.page.select.showCRSR()            else me.page.select.hideCRSR();
    if (grp == NearestVORController.UIGROUP.FREQ) me.page.highlightTextElement("Freq") else me.page.unhighlightTextElement("Freq");
    me._crsrToggle = 1;
  },


  # Input Handling
  handleCRSR : func() {
    me._crsrToggle = (! me._crsrToggle);
    if (me._crsrToggle) {
      me.page.topMenu(me.page.device, me.page, nil);
      me.page.selectVOR();
      me.selectVOR();
    } else {
      me.page.hideCRSR();
    }

    return emesary.Transmitter.ReceiptStatus_Finished;
  },
  handleFMSInner : func(value) {
    if (me._crsrToggle == 1) {
      if (me._currentGroup == NearestVORController.UIGROUP.VOR) {
        # Scroll through whatever is the current list
        me.page.select.incrSmall(value);
        var id = me.page.select.getValue();
        var data = me.getNavDataItem(id);
        if ((data != nil) and (size(data) >0)) me.page.updateNavDataItem(data[0]);
      }
      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return me.page.mfd.SurroundController.handleFMSInner(value);
    }
  },
  handleFMSOuter : func(value) {
    if (me._crsrToggle == 1) {
    if (me._currentGroup == NearestVORController.UIGROUP.VOR) {
      # Scroll through whatever is the current list
      me.page.select.incrSmall(value);
      var id = me.page.select.getValue();
      var data = me.getNavDataItem(id);
      if ((data != nil) and (size(data) >0)) me.page.updateNavDataItem(data[0]);
    }
      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return me.page.mfd.SurroundController.handleFMSOuter(value);
    }
  },
  handleEnter : func(value) {
    if (me._crsrToggle == 1) {
      if (me._currentGroup == NearestVORController.UIGROUP.VOR) {
        # Scroll through whatever is the current list
        me.page.select.incrSmall(value);
        var id = me.page.select.getValue();
        var data = me.getNavDataItem(id);
        if ((data != nil) and (size(data) >0)) me.page.updateNavDataItem(data[0]);
      }
      if (me._currentGroup == NearestVORController.UIGROUP.FREQ) {
        var freq = me.page.getTextValue("Freq");
        if (freq != nil) {
          me.page.mfd.SurroundController.setStandbyNavComFreq(freq);
        }
      }

      return emesary.Transmitter.ReceiptStatus_Finished;
    } else {
      return emesary.Transmitter.ReceiptStatus_NotProcessed;
    }
  },

  handleRange : func(val)
  {
    # Pass any range entries to the NavMapController
    me.page.mfd.NavigationMap.getController().handleRange(val);
  },

  # Reset controller if required when the page is displayed or hidden
  ondisplay : func() {
    me.RegisterWithEmesary();
    var fixes = me.getNearestNavData("vor");
    me.page.updateNavData(fixes);
    me.page.mfd.NavigationMap.getController().enableDTO(1);
    me._crsrToggle = 0;
    me.page.hideCRSR();
  },
  offdisplay : func() {
    me.page.mfd.NavigationMap.getController().enableDTO(0);
    me.DeRegisterWithEmesary();
  },

  getNearestNavData : func(type) {
    var notification = notifications.PFDEventNotification.new(
      "MFD",
      me.getDeviceID(),
      notifications.PFDEventNotification.NavData,
      {Id: "NavDataWithinRange", Value: type});

    var response = me._transmitter.NotifyAll(notification);

    if (! me._transmitter.IsFailed(response)) {
      return notification.EventParameter.Value;
    } else {
      return nil;
    }
  },

  getNavDataItem : func(id) {
    # Use Emesary to get the Navigation data
    var notification = notifications.PFDEventNotification.new(
      "MFD",
      me.getDeviceID(),
      notifications.PFDEventNotification.NavData,
      {Id: "NavAidByID", Value: { id: id, type: "vor"} });

    var response = me._transmitter.NotifyAll(notification);

    if (! me._transmitter.IsFailed(response)) {
      return notification.EventParameter.Value;
    } else {
      return nil;
    }
  },
};
