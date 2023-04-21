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
