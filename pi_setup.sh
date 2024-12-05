#!/bin/bash

# Function to check if script is running interactively
is_interactive() {
    [[ "$1" == "--interactive" ]] || [ -t 0 -a -t 1 ]
}

# Function to ask for yes/no confirmation
confirm() {
    if is_interactive "$1"; then
        read -p "$1 (y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    else
        # If not interactive, assume yes for all prompts
        return 0
    fi
}

# Check if running in interactive mode
INTERACTIVE_MODE="$1"

# System update
if confirm "Do you want to update the system?"; then
    echo "Updating system packages..."
    sudo apt update && sudo apt dist-upgrade -y && sudo apt upgrade -y && sudo apt autoremove -y
fi

# VNC Server
if confirm "Do you want to install and enable VNC server?"; then
    echo "Installing RealVNC server..."
    sudo apt update
    sudo apt install -y realvnc-vnc-server
    echo "Enabling VNC..."
    sudo raspi-config nonint do_vnc 0
fi

# Bash aliases and configurations
if confirm "Do you want to add useful bash aliases and configurations?"; then
    # Check if .bashrc exists
    if [ ! -f ~/.bashrc ]; then
        echo "Creating .bashrc file..."
        touch ~/.bashrc
    fi

    echo "Adding configurations to .bashrc..."

    if ! grep -q "alias update='sudo -- sh -c \"apt update && apt upgrade -y\"'" ~/.bashrc; then
        echo -e "\n# update our debian/ubuntu box" >> ~/.bashrc
        echo "alias update='sudo -- sh -c \"apt update && apt upgrade -y\"'" >> ~/.bashrc
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
fi

# Neofetch installation
if confirm "Do you want to install and configure neofetch?"; then
    if ! command -v neofetch &> /dev/null; then
        echo "Installing neofetch..."
        sudo apt update
        sudo apt install -y neofetch
    fi
    
    if ! grep -q "^neofetch" ~/.bashrc; then
        echo -e "\n# start neofetch at SSH login" >> ~/.bashrc
        echo "neofetch" >> ~/.bashrc
    fi
fi

# Mouse cursor hiding
if confirm "Do you want to hide the mouse cursor?"; then
    echo "Installing required development packages..."
    sudo apt update
    sudo apt install -y libglibmm-2.4-dev libglm-dev libxml2-dev libpango1.0-dev \
        libcairo2-dev libwlroots-dev libwf-config-dev \
        vulkan-tools mesa-vulkan-drivers \
        meson ninja-build pkg-config cmake \
        nlohmann-json3-dev

    # First install Wayfire from source
    echo "Building Wayfire..."
    cd ~
    rm -rf wayfire
    git clone https://github.com/WayfireWM/wayfire.git
    cd wayfire
    meson setup build --prefix=/usr --buildtype=release
    ninja -C build && sudo ninja -C build install
    cd ~

    # Now build wayfire-plugins-extra
    echo "Building wayfire-plugins-extra..."
    rm -rf wayfire-plugins-extra
    git clone https://github.com/WayfireWM/wayfire-plugins-extra
    cd wayfire-plugins-extra
    meson setup build --prefix=/usr --buildtype=release
    ninja -C build && sudo ninja -C build install

    # Create wayfire config directory
    mkdir -p ~/.config

    # Configure wayfire to use hide_cursor plugin
    cat > ~/.config/wayfire.ini << EOF
[core]
plugins = \\
        autostart \\
        hide-cursor
EOF
fi

# Ask for reboot
if confirm "Do you want to reboot the system now?"; then
    echo "System will reboot in 10 seconds..."
    echo "Press Ctrl+C to cancel reboot"

    # Countdown
    for i in {10..1}
    do
        echo -ne "\rRebooting in $i seconds... "
        sleep 1
    done

    echo -e "\rRebooting now...            "
    sudo reboot
else
    echo "Please reboot your system manually to apply all changes."
fi
