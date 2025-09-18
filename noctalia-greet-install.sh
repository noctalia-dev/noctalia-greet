#!/usr/bin/env bash

# Noctalia Greet installer script
# Run this as your regular user (not root) on a system with greetd installed.

set -e

# Prompt for username (defaults to current user)
USER_NAME="${USER}"
read -rp "Enter the username to run Noctalia Greet as [$USER_NAME]: " input
if [ -n "$input" ]; then
  USER_NAME="$input"
fi

# Clone noctalia-greet repo if not already present
if [ ! -d "noctalia-greet" ]; then
  echo "Cloning noctalia-greet repository..."
  git clone https://github.com/noctalia-dev/noctalia-greet
else
  echo "Directory noctalia-greet already exists, skipping clone."
fi

# Create config directory
CONFIG_DIR="/home/$USER_NAME/.config/quickshell/noctalia-greet"
echo "Creating $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"

# Copy files
echo "Copying files..."
cp -r noctalia-greet/* "$CONFIG_DIR/"

# Make greeter script executable
chmod +x "$CONFIG_DIR/Assets/noctalia-greet.sh"

# Write greetd config
CONFIG_TOML="/etc/greetd/config.toml"
echo "Updating $CONFIG_TOML (requires sudo)..."
sudo bash -c "cat > $CONFIG_TOML" <<EOF
[terminal]
vt = 1

[default_session]
command = "/home/$USER_NAME/.config/quickshell/noctalia-greet/Assets/noctalia-greet.sh"
user = "$USER_NAME"
EOF

# Enable and start greetd
echo "Enabling greetd..."
sudo systemctl enable greetd
sudo systemctl start greetd

echo "Installation complete!"
echo "You can test by running: sudo systemctl restart greetd"
echo "Then switch to VT1 (Ctrl+Alt+F1) to see the greeter."
