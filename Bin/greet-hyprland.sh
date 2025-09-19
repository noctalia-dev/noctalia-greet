#!/bin/sh

# Force Qt to use Wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export EGL_PLATFORM=gbm

# Resolve Assets directory
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1; pwd -P)"
ASSETS_DIR="$(cd -- "$SCRIPT_DIR/.." >/dev/null 2>&1; pwd -P)/Assets"

exec hyprland -c "$ASSETS_DIR/hypr-noctalia.conf"


