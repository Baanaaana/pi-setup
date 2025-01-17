#!/bin/bash

echo "Setting up kiosk mode..."

# Install required packages
sudo apt install -y chromium-browser

# Configure autologin using raspi-config
echo "Configuring autologin..."
sudo raspi-config nonint do_boot_behaviour B4

# Create Wayfire config directory
mkdir -p ~/.config

# Create or update Wayfire config
cat > ~/.config/wayfire.ini << 'EOF'
[autostart]
chromium = chromium-browser 'https://dashboard.rrcommerce.nl' --kiosk --noerrdialogs --disable-infobars --no-first-run --ozone-platform=wayland --enable-features=OverlayScrollbar --start-maximized
screensaver = false
dpms = false
EOF

echo "Kiosk mode setup complete! Please reboot your system."
echo "After reboot, the dashboard will start automatically in kiosk mode." 