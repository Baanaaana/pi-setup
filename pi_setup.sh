#!/bin/bash

# Update system first
echo "Updating system packages..."
sudo apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && sudo apt autoremove -y

# Install RealVNC server
echo "Installing RealVNC server..."
sudo apt update
sudo apt install -y realvnc-vnc-server
echo "Enabling VNC..."
sudo raspi-config nonint do_vnc 0

# Disable onscreen keyboard for Wayfire
echo "Disabling onscreen keyboard for Wayfire..."
if [ -f /etc/xdg/autostart/matchbox-keyboard.desktop ]; then
    sudo mv /etc/xdg/autostart/matchbox-keyboard.desktop /etc/xdg/autostart/matchbox-keyboard.desktop.disabled
fi

# Additionally, disable any Wayfire-specific onscreen keyboard settings
WAYFIRE_CONFIG_DIR=~/.config/wayfire
WAYFIRE_CONFIG_FILE=$WAYFIRE_CONFIG_DIR/wayfire.ini

if [ -d "$WAYFIRE_CONFIG_DIR" ]; then
    if [ ! -f "$WAYFIRE_CONFIG_FILE" ]; then
        echo "Creating Wayfire configuration file..."
        mkdir -p "$WAYFIRE_CONFIG_DIR"
        touch "$WAYFIRE_CONFIG_FILE"
    fi

    if ! grep -q "disable-onscreen-keyboard" "$WAYFIRE_CONFIG_FILE"; then
        echo "Disabling onscreen keyboard in Wayfire configuration..."
        echo -e "\n[onscreen-keyboard]\nenabled = false" >> "$WAYFIRE_CONFIG_FILE"
    fi
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
