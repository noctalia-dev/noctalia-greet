#!/bin/sh

# Force Qt to use Wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export EGL_PLATFORM=gbm

# Resolve repo root and Assets directory
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" >/dev/null 2>&1; pwd -P)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." >/dev/null 2>&1; pwd -P)"
ASSETS_DIR="$ROOT_DIR/Assets"

# Create a temp config with absolute path substitution (no envs)
TMP_CFG="$(mktemp)"
sed "s#__NOCTALIA_GREET_DIR__#${ROOT_DIR}#g" "$ASSETS_DIR/niri-noctalia.kdl" > "$TMP_CFG"

exec niri -c "$TMP_CFG"


