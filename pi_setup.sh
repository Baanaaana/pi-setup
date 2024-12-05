#!/bin/bash

# Function to ask for yes/no confirmation
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

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

    # Add all the .bashrc configurations here...
    if ! grep -q "alias update='sudo -- sh -c \"apt update && apt upgrade -y\"'" ~/.bashrc; then
        echo -e "\n# update our debian/ubuntu box" >> ~/.bashrc
        echo "alias update='sudo -- sh -c \"apt update && apt upgrade -y\"'" >> ~/.bashrc
    fi

    # Add all other aliases...
    # [Previous alias configurations remain the same]
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

# Wayfire cursor hiding
if confirm "Do you want to install wayfire-plugins-extra to hide the mouse cursor?"; then
    echo "Installing required development packages..."
    sudo apt update
    sudo apt install -y libglibmm-2.4-dev libglm-dev libxml2-dev libpango1.0-dev \
        libcairo2-dev wayfire-dev libwlroots-dev libwf-config-dev meson ninja-build \
        vulkan-tools vulkan-validationlayers-dev cmake \
        libvulkan-dev vulkan-headers vulkan-validationlayers vulkan-tools

    # Set PKG_CONFIG_PATH for vulkan and create symlink if needed
    sudo mkdir -p /usr/lib/aarch64-linux-gnu/pkgconfig
    sudo ln -sf /usr/share/vulkan/registry/vulkan.pc /usr/lib/aarch64-linux-gnu/pkgconfig/vulkan.pc
    export PKG_CONFIG_PATH="/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/vulkan/registry:$PKG_CONFIG_PATH"

    # Clone and build wayfire-plugins-extra
    echo "Building wayfire-plugins-extra..."
    cd ~
    rm -rf wayfire-plugins-extra
    git clone https://github.com/seffs/wayfire-plugins-extra/
    cd wayfire-plugins-extra

    rm -rf build
    mkdir build
    meson setup build
    ninja -C build
    sudo ninja -C build install

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
