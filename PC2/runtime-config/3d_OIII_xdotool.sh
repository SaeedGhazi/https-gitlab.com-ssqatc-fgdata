#!/bin/bash
# =============================================
# Optimized FlightGear for RTX 3050 + Openbox
# =============================================

rm -f ~/.fgfs/navdata_2024_1.cache

export DISPLAY=:0
export __GL_SYNC_TO_VBLANK=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json

echo "🚀 Starting FlightGear (Optimized)..."

./run --fg-root=. \
      --fg-scenery=./Scenery_OIII/ \
      --airport=OIII \
      --aircraft=ufo \
      --ai-scenario=SSQ \
      --timeofday=noon \
      --disable-terrasync \
      --enable-texture-cache \
      --disable-ai-traffic \
      --log-level=warn \
      --lat=35.690221 \
      --lon=51.322259 \
      --altitude=7000 \
      --splash-screen=false \
      --enable-ai-models \
      --visibility=20000 \
      --heading=99.7 \
      --disable-gui \
      --disable-panel \
      --telnet=5000 \
      --allow-nasal-read=/home/ssq/.fgfs \
      --prop:/sim/startup/xsize=7680 \
      --prop:/sim/startup/ysize=1080 \
      --prop:/sim/rendering/multi-sample-buffers=true \
      --prop:/sim/rendering/multi-samples=2 \
      --prop:/sim/rendering/shaders/use-shaders=true \
      --prop:/sim/rendering/shadows/enabled=false \
      --prop:/sim/rendering/dynamic-lighting/enabled=false \
      --prop:/sim/rendering/random-vegetation=false \
      --prop:/sim/rendering/random-objects=false \
      --prop:/sim/rendering/random-buildings=false \
      --prop:/sim/model-hz=60 \
      --prop:/sim/frame-rate-throttle-hz=60 &

echo "⏳ Waiting for windows (up to 60s)..."

for i in {1..60}; do
    COUNT=$(xdotool search --name "OIII_" 2>/dev/null | wc -l)
    if [ "$COUNT" -ge 4 ]; then
        echo "✅ Found $COUNT windows!"
        break
    fi
    sleep 1
done

sleep 5

echo "📍 Positioning windows..."
xdotool search --name "^OIII$" windowsize 400 300 windowmove 0 0
xdotool search --name "OIII_1" windowmove 0 0     windowraise windowactivate
xdotool search --name "OIII_2" windowmove 1920 0  windowraise windowactivate
xdotool search --name "OIII_3" windowmove 3840 0  windowraise windowactivate
xdotool search --name "OIII_4" windowmove 5760 0  windowraise windowactivate

xdotool search --name "^OIII$" windowminimize 2>/dev/null || true

echo "🎉 Done! Check FPS with Shift+F"
