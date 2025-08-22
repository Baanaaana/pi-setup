#!/bin/bash

# Get the actual user running the script (not root)
ACTUAL_USER="${SUDO_USER:-$USER}"
USER_HOME=$(eval echo ~$ACTUAL_USER)

# Update system first
echo "Updating system packages..."
sudo apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && sudo apt autoremove -y

# Install and configure unattended-upgrades for automatic updates
echo "Installing unattended-upgrades..."
sudo apt install -y unattended-upgrades apt-listchanges

echo "Configuring unattended-upgrades..."
# Enable automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades

# Configure unattended-upgrades settings
sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null <<EOF
Unattended-Upgrade::Origins-Pattern {
    "origin=Debian,codename=\${distro_codename}-updates";
    "origin=Debian,codename=\${distro_codename}-proposed-updates";
    "origin=Debian,codename=\${distro_codename},label=Debian";
    "origin=Debian,codename=\${distro_codename},label=Debian-Security";
    "origin=Raspbian,codename=\${distro_codename},label=Raspbian";
    "origin=Raspberry Pi Foundation,codename=\${distro_codename},label=Raspberry Pi Foundation";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
EOF

# Configure automatic update schedule
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

echo "Unattended-upgrades configured successfully!"

# Install RealVNC server
echo "Installing RealVNC server..."
sudo apt update
sudo apt install -y realvnc-vnc-server
echo "Enabling VNC..."
sudo raspi-config nonint do_vnc 0

# Bash aliases and configurations
# Check if .bashrc exists
if [ ! -f "$USER_HOME/.bashrc" ]; then
    echo "Creating .bashrc file..."
    sudo -u $ACTUAL_USER touch "$USER_HOME/.bashrc"
fi

echo "Adding configurations to .bashrc..."

if ! grep -q "alias update='sudo -- sh -c \"apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && sudo apt autoremove -y\"'" "$USER_HOME/.bashrc"; then
    echo -e "\n# update our debian/ubuntu box" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    echo "alias update='sudo -- sh -c \"apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && sudo apt autoremove -y\"'" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
fi

if ! grep -q "alias temp='/usr/bin/vcgencmd measure_temp'" "$USER_HOME/.bashrc"; then
    echo -e "\n# check raspberry pi temperature" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    echo "alias temp='/usr/bin/vcgencmd measure_temp'" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
fi

if ! grep -q "alias boot='sudo nano /boot/firmware/config.txt'" "$USER_HOME/.bashrc"; then
    echo -e "\n# quick edit boot config" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    echo "alias boot='sudo nano /boot/firmware/config.txt'" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
fi

if ! grep -q "alias autostart='sudo nano /etc/xdg/lxsession/LXDE-pi/autostart'" "$USER_HOME/.bashrc"; then
    echo -e "\n# quick edit autostart config" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    echo "alias autostart='sudo nano /etc/xdg/lxsession/LXDE-pi/autostart'" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
fi

if ! grep -q "alias cron='sudo crontab -e'" "$USER_HOME/.bashrc"; then
    echo -e "\n# quick edit crontab" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    echo "alias cron='sudo crontab -e'" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
fi

if ! grep -q "^echo \"\"" "$USER_HOME/.bashrc"; then
    echo -e "\n# add blank line" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    echo "echo \"\"" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
fi

if ! grep -q "^clear" "$USER_HOME/.bashrc"; then
    echo -e "\n# clear default message" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    echo "clear" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
fi

# Neofetch installation
if ! command -v neofetch &> /dev/null; then
    echo "Installing neofetch..."
    sudo apt update
    sudo apt install -y neofetch
fi

if ! grep -q "^neofetch" "$USER_HOME/.bashrc"; then
    echo -e "\n# start neofetch at SSH login" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
    echo "neofetch" | sudo -u $ACTUAL_USER tee -a "$USER_HOME/.bashrc" > /dev/null
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
