# Raspberry Pi Setup Script

A simple bash script to customize your Raspberry Pi's terminal configuration. This script modifies your `.bashrc` file to add useful aliases and configurations.

## Features

The script will:
- Update and upgrade all system packages first
- Install and enable RealVNC server for remote access
- Add useful aliases for common Raspberry Pi tasks:
  - `update`: Easy system updates
  - `temp`: Check Raspberry Pi temperature
  - `boot`: Quick edit boot configuration
  - `autostart`: Quick edit autostart configuration
  - `cron`: Quick edit crontab
- Clear the default terminal message
- Add a blank line for better readability
- Install and configure neofetch to display system information at login
- Install and configure wayfire-plugins-extra to hide mouse cursor
- Avoid duplicate entries by checking existing configurations

## Quick Installation

Run this command to automatically download and execute the script:

```bash
curl -sSL https://raw.githubusercontent.com/Baanaaana/pi-setup/main/pi_setup.sh | bash
```

## Manual Installation

If you prefer to review the script before running it (recommended), you can:

1. Download the script:

```bash
curl -O https://raw.githubusercontent.com/Baanaaana/pi-setup/main/pi_setup.sh
```

2. Make it executable:

```bash
chmod +x pi_setup.sh
```

3. Run the script:

```bash
./pi_setup.sh
```

## What Gets Added to .bashrc

The script adds the following configurations to your `.bashrc`:

```bash
# update our debian/ubuntu box
alias update='sudo -- sh -c "apt update && apt upgrade -y"'

# check raspberry pi temperature
alias temp='/usr/bin/vcgencmd measure_temp'

# quick edit boot config
alias boot='sudo nano /boot/firmware/config.txt'

# quick edit autostart config
alias autostart='sudo nano /etc/xdg/lxsession/LXDE-pi/autostart'

# quick edit crontab
alias cron='sudo crontab -e'

# add blank line
echo ""

# clear default message
clear

# start neofetch at SSH login
neofetch
```

## What Gets Added

The script makes the following changes:

1. Installs and enables RealVNC server

2. To `~/.config/wayfire.ini`:

```ini
[core]
plugins = \
        autostart \
        hide-cursor
```

## Requirements

- Raspberry Pi running Raspberry Pi OS (or other Debian-based Linux)
- Internet connection (for installing required packages)
- Basic terminal access
- Wayland display server
- Development packages for building wayfire-plugins-extra

## After Installation

The script will:
- Automatically reboot your system after a 10-second countdown
- You can press Ctrl+C to cancel the automatic reboot
- After reboot:
  - All configurations will be active
  - VNC server will be enabled and ready to use
  - The mouse cursor will be permanently hidden
  - Use touchscreen or mouse movement to navigate
  - All aliases will be available for use

## Available Aliases

After installation, you can use these shortcuts:
- `update`: Update and upgrade system packages
- `temp`: Show current CPU temperature
- `boot`: Edit the boot configuration file
- `autostart`: Edit the autostart configuration file
- `cron`: Edit the root crontab

## License

This project is open source and available under the [MIT License](LICENSE).

## Remote Access

After installation, you can connect to your Raspberry Pi using:
- VNC Viewer (download from RealVNC website)
- Default port: 5900
- Use your Raspberry Pi's IP address and login credentials
