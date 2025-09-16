#!/bin/sh

# Force Qt to use Wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export EGL_PLATFORM=gbm

# Launch with minimal config in a new VT. Use exec so greetd can kill it on login.
exec niri -c /mnt/storage/GitHub/noctalia-dev/noctalia-greet/Assets/niri-noctalia.kdl
#exec hyprland -c /mnt/storage/GitHub/noctalia-dev/noctalia-greet/Assets/hypr-noctalia.conf
