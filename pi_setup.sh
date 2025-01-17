#!/bin/bash

# Function to check if script is running interactively
is_interactive() {
    [ -t 0 ]
}

# Update system first
echo "Updating system packages..."
sudo apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && sudo apt autoremove -y

# Install RealVNC server
echo "Installing RealVNC server..."
sudo apt update
sudo apt install -y realvnc-vnc-server
echo "Enabling VNC..."
sudo raspi-config nonint do_vnc 0

# Install and configure kiosk mode if interactive
if is_interactive; then
    echo "Do you want to set up kiosk mode for the dashboard? (y/n)"
    read -r setup_kiosk
    if [[ $setup_kiosk =~ ^[Yy]$ ]]; then
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
    fi
else
    echo "Running in non-interactive mode. Skipping kiosk mode setup."
fi

# Bash aliases and configurations
# Check if .bashrc exists
if [ ! -f ~/.bashrc ]; then
    echo "Creating .bashrc file..."
    touch ~/.bashrc
fi

echo "Adding configurations to .bashrc..."

if ! grep -q "alias update='sudo -- sh -c \"apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && sudo apt autoremove -y\"'" ~/.bashrc; then
    echo -e "\n# update our debian/ubuntu box" >> ~/.bashrc
    echo "alias update='sudo -- sh -c \"apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && sudo apt autoremove -y\"'" >> ~/.bashrc
fi

if ! grep -q "alias temp='/usr/bin/vcgencmd measure_temp'" ~/.bashrc; then
    echo -e "\n# check raspberry pi temperature" >> ~/.bashrc
    echo "alias temp='/usr/bin/vcgencmd measure_temp'" >> ~/.bashrc
fi

if ! grep -q "alias boot='sudo nano /boot/firmware/config.txt'" ~/.bashrc; then
    echo -e "\n# quick edit boot config" >> ~/.bashrc
    echo "alias boot='sudo nano /boot/firmware/config.txt'" >> ~/.bashrc
fi

if ! grep -q "alias autostart='sudo nano /etc/xdg/lxsession/LXDE-pi/autostart'" ~/.bashrc; then
    echo -e "\n# quick edit autostart config" >> ~/.bashrc
    echo "alias autostart='sudo nano /etc/xdg/lxsession/LXDE-pi/autostart'" >> ~/.bashrc
fi

if ! grep -q "alias cron='sudo crontab -e'" ~/.bashrc; then
    echo -e "\n# quick edit crontab" >> ~/.bashrc
    echo "alias cron='sudo crontab -e'" >> ~/.bashrc
fi

if ! grep -q "^echo \"\"" ~/.bashrc; then
    echo -e "\n# add blank line" >> ~/.bashrc
    echo "echo \"\"" >> ~/.bashrc
fi

if ! grep -q "^clear" ~/.bashrc; then
    echo -e "\n# clear default message" >> ~/.bashrc
    echo "clear" >> ~/.bashrc
fi

# Neofetch installation
if ! command -v neofetch &> /dev/null; then
    echo "Installing neofetch..."
    sudo apt update
    sudo apt install -y neofetch
fi

if ! grep -q "^neofetch" ~/.bashrc; then
    echo -e "\n# start neofetch at SSH login" >> ~/.bashrc
    echo "neofetch" >> ~/.bashrc
fi

echo "Setup complete! System will reboot in 10 seconds..."
echo "Press Ctrl+C to cancel reboot"

# Countdown
for i in {10..1}
do
    echo -ne "\rRebooting in $i seconds... "
    sleep 1
done

echo -e "\rRebooting now...            "
sudo reboot
