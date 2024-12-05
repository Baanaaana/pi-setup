# Raspberry Pi Setup Script

A script to customize your Raspberry Pi's terminal configuration. This script modifies your `.bashrc` file to add useful aliases and configurations.

## Features

The script offers the following optional configurations:
- System update and upgrade (including kept-back packages)
- VNC server installation and configuration
- Useful bash aliases and configurations:
  - `update`: Easy system updates
  - `temp`: Check Raspberry Pi temperature
  - `boot`: Quick edit boot configuration
  - `autostart`: Edit the autostart configuration
  - `cron`: Quick edit crontab
- Neofetch installation and configuration
- Automatic reboot after installation

## Installation

Run this command to automatically download and execute the script:

```bash
curl -sSL https://raw.githubusercontent.com/Baanaaana/pi-setup/main/pi_setup.sh | bash
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

## Requirements

- Raspberry Pi running Raspberry Pi OS (or other Debian-based Linux)
- Internet connection (for installing required packages)
- Basic terminal access

## After Installation

The script will:
- Automatically reboot your system after a 10-second countdown
- You can press Ctrl+C to cancel the automatic reboot
- After reboot:
  - All configurations will be active
  - VNC server will be enabled and ready to use
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
