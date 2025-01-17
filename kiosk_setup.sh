#!/bin/bash

echo "Setting up kiosk mode..."

# Install required packages
sudo apt install -y chromium-browser wtype

# Configure autologin using raspi-config
echo "Configuring autologin..."
sudo raspi-config nonint do_boot_behaviour B4

# Create Wayfire config directory
mkdir -p ~/.config

# Create or update Wayfire config
cat > ~/.config/wayfire.ini << 'EOF'
[autostart]
chromium = chromium-browser 'https://dashboard.rrcommerce.nl' --kiosk --noerrdialogs --disable-infobars --no-first-run --ozone-platform=wayland --enable-features=OverlayScrollbar --start-maximized
switchtab = bash ~/switchtab.sh
screensaver = false
dpms = false
EOF

# Create script to handle browser crashes and tab switching
cat > ~/switchtab.sh << 'EOF'
#!/bin/bash

# Find Chromium browser process ID
chromium_pid=$(pgrep chromium | head -1)

# Check if Chromium is running
while [ -z $chromium_pid ]; do
  echo "Chromium browser is not running yet."
  sleep 5
  chromium_pid=$(pgrep chromium | head -1)
done

echo "Chromium browser process ID: $chromium_pid"

export XDG_RUNTIME_DIR=/run/user/1000

# Loop to send keyboard events
while true; do
  # Send Ctrl+Tab using wtype command
  wtype -M ctrl -P Tab
  wtype -m ctrl -p Tab
  sleep 15
done
EOF

# Make switchtab.sh executable
chmod +x ~/switchtab.sh

echo "Kiosk mode setup complete! Please reboot your system."
echo "After reboot, the dashboard will start automatically in kiosk mode." 