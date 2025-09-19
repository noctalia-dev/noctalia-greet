#!/usr/bin/env bash

# Noctalia Greet installer script
# Run this as your regular user (not root) on a system with greetd installed.

set -e

# Config
CONFIG_DIR="$HOME/.config/quickshell/noctalia/noctalia-greet"
GREETER_SCRIPT="$CONFIG_DIR/Assets/noctalia-greet.sh"
GREETD_CONFIG="/etc/greetd/config.toml"

# Clone or update the repo
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Cloning noctalia-greet repository into $CONFIG_DIR..."
    git clone git@github.com:noctalia-dev/noctalia-greet.git "$CONFIG_DIR"
else
    echo "Repository already exists, updating with git pull..."
    cd "$CONFIG_DIR"
    git pull
fi

# Make the greeter script executable
if [ ! -f "$GREETER_SCRIPT" ]; then
    echo "Error: Greeter script not found at $GREETER_SCRIPT"
    exit 1
fi
chmod +x "$GREETER_SCRIPT"

# Write greetd configuration
echo "Updating $GREETD_CONFIG (requires sudo)..."
sudo bash -c "cat > $GREETD_CONFIG" <<EOF
[terminal]
vt = 1

[default_session]
command = "$GREETER_SCRIPT"
user = "$USER"
EOF

# Enable and start greetd
echo "Enabling greetd..."
sudo systemctl enable greetd
sudo systemctl start greetd

echo "Installation complete!"
echo "You can test by running: sudo systemctl restart greetd"
echo "Then switch to VT1 (Ctrl+Alt+F1) to see the greeter."
