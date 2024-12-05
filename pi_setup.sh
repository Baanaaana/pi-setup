#!/bin/bash

# Update system first
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Check if .bashrc exists
if [ ! -f ~/.bashrc ]; then
    echo "Creating .bashrc file..."
    touch ~/.bashrc
fi

# Add configurations to .bashrc
echo "Adding configurations to .bashrc..."

# Check if the configurations already exist to avoid duplicates
if ! grep -q "alias update='sudo -- sh -c \"apt update && apt upgrade -y\"'" ~/.bashrc; then
    echo -e "\n# update our debian/ubuntu box" >> ~/.bashrc
    echo "alias update='sudo -- sh -c \"apt update && apt upgrade -y\"'" >> ~/.bashrc
fi

# Add additional useful aliases
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

if ! grep -q "^neofetch" ~/.bashrc; then
    echo -e "\n# start neofetch at SSH login" >> ~/.bashrc
    echo "neofetch" >> ~/.bashrc
fi

# Check if neofetch is installed
if ! command -v neofetch &> /dev/null; then
    echo "Installing neofetch..."
    sudo apt update
    sudo apt install -y neofetch
fi

# Check if unclutter is installed
if ! command -v unclutter &> /dev/null; then
    echo "Installing unclutter..."
    sudo apt update
    sudo apt install -y unclutter
fi

# Create system-wide autostart directory if it doesn't exist
sudo mkdir -p /etc/xdg/lxsession/LXDE-pi

# Configure unclutter in LXDE-pi autostart
if ! grep -q "unclutter" /etc/xdg/lxsession/LXDE-pi/autostart; then
    echo "@unclutter -idle 0" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart
fi

# Start unclutter in current session
if ! pgrep unclutter > /dev/null; then
    unclutter -idle 0 &
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
