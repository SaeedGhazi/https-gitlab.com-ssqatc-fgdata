# Copyright (C) 2023 Fernando García Liñán
# SPDX-License-Identifier: GPL-2.0-or-later

#-------------------------------------------------------------------------------
# Utilities for the HDR Pipeline
#
# Shaders usually need to be fed uniforms that are either too expensive to
# compute on the GPU or can be precomputed once per frame. In this file we
# transform values from already existing properties into data that can be used
# by the shaders directly.
#-------------------------------------------------------------------------------

################################################################################
# Atmosphere
################################################################################
setprop("/sim/rendering/hdr/atmos/aerosol-absorption-cross-section[0]", 2.8722e-24);
setprop("/sim/rendering/hdr/atmos/aerosol-absorption-cross-section[1]", 4.6168e-24);
setprop("/sim/rendering/hdr/atmos/aerosol-absorption-cross-section[2]", 7.9706e-24);
setprop("/sim/rendering/hdr/atmos/aerosol-absorption-cross-section[3]", 1.3578e-23);

setprop("/sim/rendering/hdr/atmos/aerosol-scattering-cross-section[0]", 1.5908e-22);
setprop("/sim/rendering/hdr/atmos/aerosol-scattering-cross-section[1]", 1.7711e-22);
setprop("/sim/rendering/hdr/atmos/aerosol-scattering-cross-section[2]", 2.0942e-22);
setprop("/sim/rendering/hdr/atmos/aerosol-scattering-cross-section[3]", 2.4033e-22);

setprop("/sim/rendering/hdr/atmos/aerosol-base-density", 1.3681e17);
setprop("/sim/rendering/hdr/atmos/aerosol-relative-background-density", 1.4619e-17);
setprop("/sim/rendering/hdr/atmos/aerosol-scale-height", 0.73);
setprop("/sim/rendering/hdr/atmos/fog-density", 0.0);
setprop("/sim/rendering/hdr/atmos/fog-scale-height", 1.0);
setprop("/sim/rendering/hdr/atmos/ozone-mean-dobson", 347.0);

setprop("/sim/rendering/hdr/atmos/ground-albedo[0]", 0.4);
setprop("/sim/rendering/hdr/atmos/ground-albedo[1]", 0.4);
setprop("/sim/rendering/hdr/atmos/ground-albedo[2]", 0.4);
setprop("/sim/rendering/hdr/atmos/ground-albedo[3]", 0.4);

################################################################################
# Environment map
################################################################################
var envmap_frame_listener = nil;
var is_envmap_updating = false;
var is_prefiltering_active = false;
var current_envmap_face = 0;

var envmap_update_frame = func {
    if (is_prefiltering_active) {
        # Last frame we activated the prefiltering, which is the last step.
        # Now disable it and reset all variables for the next update cycle.
        removelistener(envmap_frame_listener);
        setprop("/sim/rendering/hdr/envmap/should-prefilter", false);
        is_prefiltering_active = false;
        is_envmap_updating = false;
        return;
    }
    if (current_envmap_face < 6) {
        # Render the current face
        setprop("/sim/rendering/hdr/envmap/should-render-face-"
                ~ current_envmap_face, true);
    }
    if (current_envmap_face > 0) {
        # Stop rendering the previous face
        setprop("/sim/rendering/hdr/envmap/should-render-face-"
                ~ (current_envmap_face - 1), false);
    }
    if (current_envmap_face < 6) {
        # Go to next face and update it next frame
        current_envmap_face += 1;
    } else {
        # We have finished updating all faces. Reset the face counter and
        # prefilter the envmap.
        current_envmap_face = 0;
        is_prefiltering_active = true;
        setprop("/sim/rendering/hdr/envmap/should-prefilter", true);
    }
}

var update_envmap = func {
    if (!is_envmap_updating) {
        is_envmap_updating = true;
        # We use a listener to the frame signal because it is guaranteed to be
        # fired at a defined moment, while a settimer() with interval 0 might
        # not if subsystems are re-ordered.
        envmap_frame_listener = setlistener("/sim/signals/frame",
                                            envmap_update_frame);
    }
}

# Manual update
setlistener("/sim/rendering/hdr/envmap/force-update", func(p) {
    if (p.getValue()) {
        update_envmap();
        p.setValue(false);
    }
}, 0, 0);

# Automatically update the envmap every so often
var envmap_timer = maketimer(getprop("/sim/rendering/hdr/envmap/update-rate-s"),
                             update_envmap);
envmap_timer.simulatedTime = true;

# Start updating when the FDM is initialized
setlistener("/sim/signals/fdm-initialized", func {
    update_envmap();
    envmap_timer.start();
    # Do a single update after 5 seconds when most of the scenery is loaded
    settimer(update_envmap, 5);
});

setlistener("/sim/rendering/hdr/envmap/update-rate-s", func(p) {
    if (envmap_timer.isRunning) {
        update_envmap();
        envmap_timer.restart(p.getValue());
    }
});

# Update the envmap much faster when time warp is active
var envmap_timer_warp = maketimer(1, update_envmap);
setlistener("/sim/time/warp-delta", func(p) {
    if (p.getValue() != 0) {
        envmap_timer_warp.start();
    } else {
        envmap_timer_warp.stop();
        # Do a final update a second later to make sure we have the correct
        # envmap for the new time of day.
        settimer(update_envmap, 1);
    }
});
