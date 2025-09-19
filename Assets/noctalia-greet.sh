#!/bin/sh

# Force Qt to use Wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export EGL_PLATFORM=gbm

# Launch with minimal config in a new VT. Use exec so greetd can kill it on login.
# Resolve the directory this script lives in (Assets/) so paths follow CONFIG_DIR
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1; pwd -P)"

exec niri -c "$SCRIPT_DIR/niri-noctalia.kdl"
#exec hyprland -c "$SCRIPT_DIR/hypr-noctalia.conf"
