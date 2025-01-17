#!/bin/bash

echo "Setting up kiosk mode..."

# Install required packages
sudo apt install -y chromium-browser

# Create Wayfire config directory
mkdir -p ~/.config/wayfire

# Create or update Wayfire config
cat > ~/.config/wayfire/wayfire.ini << 'EOF'
[core]
plugins = autostart
preferred_decoration_mode = none

[autostart]
dashboard = chromium-browser --noerrdialogs --disable-infobars --kiosk https://dashboard.rrcommerce.nl

[window-rules]
dashboard_rules = on created if app_id contains "Chromium" then fullscreen

[input]
cursor_theme = default
cursor_size = 24
mouse_cursor_speed = 0
EOF

# Create systemd user service for auto-restart
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/dashboard.service << 'EOF'
[Unit]
Description=Dashboard Kiosk
After=wayfire.service
Wants=wayfire.service

[Service]
Environment=WAYLAND_DISPLAY=wayland-1
ExecStart=/usr/bin/chromium-browser --noerrdialogs --disable-infobars --kiosk https://dashboard.rrcommerce.nl
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Enable the service
systemctl --user enable dashboard.service

# Hide mouse cursor when inactive
echo "Configuring cursor hiding..."
cat > ~/.config/wayfire/autostart << 'EOF'
#!/bin/bash
unclutter -idle 0.1 &
EOF
chmod +x ~/.config/wayfire/autostart

echo "Kiosk mode setup complete! Please reboot your system." 