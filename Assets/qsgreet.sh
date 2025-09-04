#!/bin/sh
# Minimal Niri container session for Quickshell greeter

# Force Qt to use Wayland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export EGL_PLATFORM=gbm

# Launch Niri with minimal config in a new VT. Use exec so greetd can kill it on login.
exec niri -c ~/.config/quickshell/noctalia-greet/Assets/noctalia.kdl
