# Raspberry Pi Setup Script

A simple bash script to customize your Raspberry Pi's terminal configuration. This script modifies your `.bashrc` file to add useful aliases and configurations.

## Features

The script offers the following optional configurations:
- System update and upgrade (including kept-back packages)
- VNC server installation and configuration
- Useful bash aliases and configurations:
  - `update`: Easy system updates
  - `temp`: Check Raspberry Pi temperature
  - `boot`: Quick edit boot configuration
  - `autostart`: Quick edit autostart configuration
  - `cron`: Quick edit crontab
- Neofetch installation and configuration
- Mouse cursor hiding using multiple methods
- Optional reboot after installation

## Usage

When running the script, you'll be prompted to confirm each feature:
- Answer 'y' (yes) to install/configure the feature
- Answer 'n' (no) to skip the feature

This allows you to customize your installation according to your needs.

## Quick Installation

Run one of these commands:

For automatic installation with all features enabled:
```bash
curl -sSL https://raw.githubusercontent.com/Baanaaana/pi-setup/main/pi_setup.sh | bash
```

For interactive installation with feature selection:
```bash
curl -sSL https://raw.githubusercontent.com/Baanaaana/pi-setup/main/pi_setup.sh | bash -i
```

## Manual Installation

If you prefer to choose which features to install, you can:

1. Download the script:

```bash
curl -O https://raw.githubusercontent.com/Baanaaana/pi-setup/main/pi_setup.sh
```

2. Make it executable:

```bash
chmod +x pi_setup.sh
```

3. Run the script interactively:

```bash
./pi_setup.sh
```

When running interactively, you'll be prompted to confirm each feature:
- Answer 'y' (yes) to install/configure the feature
- Answer 'n' (no) to skip the feature

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

2. To `/etc/xdg/autostart/unclutter.desktop`:

```ini
[Desktop Entry]
Type=Application
Name=Unclutter
Comment=Hide mouse cursor
Exec=unclutter --timeout 0 --fork
Terminal=false
Categories=System;
```

3. To `/etc/X11/xorg.conf.d/99-nocursor.conf`:

```conf
Section "ServerFlags"
    Option "NoCursor" "true"
EndSection
```

4. To `/etc/xdg/lxsession/LXDE-pi/autostart`:

```bash
@unclutter --timeout 0
```

## Requirements

- Raspberry Pi running Raspberry Pi OS (or other Debian-based Linux)
- Internet connection (for installing required packages)
- Basic terminal access
- Wayland display server

## After Installation

The script will:
- Automatically reboot your system after a 10-second countdown
- You can press Ctrl+C to cancel the automatic reboot
- After reboot:
  - Log out and log back in for group changes to take effect
  - All configurations will be active
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
