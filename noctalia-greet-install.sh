#!/usr/bin/env bash

# Noctalia Greet installer script
# Run this as your regular user (not root) on a system with greetd installed.

set -e

# Config
CONFIG_DIR="$HOME/.config/quickshell/noctalia-greet"
GREETER_SCRIPT_NIRI="$CONFIG_DIR/Bin/greet-niri.sh"
GREETER_SCRIPT_HYPR="$CONFIG_DIR/Bin/greet-hyprland.sh"
GREETD_CONFIG="/etc/greetd/config.toml"

# Clone or update the repo (HTTPS instead of SSH)
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Cloning noctalia-greet repository into $CONFIG_DIR..."
    git clone https://github.com/noctalia-dev/noctalia-greet.git "$CONFIG_DIR"
else
    echo "Repository already exists, updating with git pull..."
    cd "$CONFIG_DIR"
    # ensure we’re on https
    git remote set-url origin https://github.com/noctalia-dev/noctalia-greet.git
    git pull
fi

# Make the greeter scripts executable
if [ ! -f "$GREETER_SCRIPT_NIRI" ] || [ ! -f "$GREETER_SCRIPT_HYPR" ]; then
    echo "Error: Greeter scripts not found in $CONFIG_DIR/Bin"
    exit 1
fi
chmod +x "$GREETER_SCRIPT_NIRI" "$GREETER_SCRIPT_HYPR"

# Ask which compositor to use and toggle the correct exec line in the greeter script
echo "\nChoose the compositor to run the greeter under:"
echo "  1) Niri"
echo "  2) Hyprland"
read -r -p "Enter 1 or 2 [default: 1]: " COMP_CHOICE

# Default to Niri if empty
if [ -z "$COMP_CHOICE" ]; then
  COMP_CHOICE=1
fi

case "$COMP_CHOICE" in
  1|n|N)
    echo "Selected: Niri"
    SELECTED_COMMAND="$GREETER_SCRIPT_NIRI"
    ;;
  2|h|H)
    echo "Selected: Hyprland"
    SELECTED_COMMAND="$GREETER_SCRIPT_HYPR"
    ;;
  *)
    echo "Unrecognized choice '$COMP_CHOICE'. Defaulting to Niri."
    SELECTED_COMMAND="$GREETER_SCRIPT_NIRI"
    ;;
esac

# Write greetd configuration
echo "Updating $GREETD_CONFIG (requires sudo)..."
sudo bash -c "cat > $GREETD_CONFIG" <<EOF
[terminal]
vt = 1

[default_session]
command = "$SELECTED_COMMAND"
user = "$USER"
EOF

# Enable and start greetd
echo "Enabling greetd..."
sudo systemctl enable greetd
sudo systemctl start greetd

echo "Installation complete!"
echo "You can test by running: sudo systemctl restart greetd"
echo "Then switch to VT1 (Ctrl+Alt+F1) to see the greeter."
