#!/bin/bash

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

# Create system-wide LXDE-pi autostart directory if it doesn't exist
sudo mkdir -p /etc/xdg/lxsession/LXDE-pi

# Configure unclutter and screensaver settings
sudo tee /etc/xdg/lxsession/LXDE-pi/autostart << EOF
@lxpanel --profile LXDE
@pcmanfm --desktop --profile LXDE
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 0
EOF

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
