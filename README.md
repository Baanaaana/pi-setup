# Raspberry Pi Setup Script

A script to customize your Raspberry Pi's terminal configuration. This script modifies your `.bashrc` file to add useful aliases and configurations.

## Features

The script offers the following configurations:
- System update and upgrade (including kept-back packages)
- Automatic security updates via unattended-upgrades
- VNC server installation and configuration
- Useful bash aliases and configurations
- Fastfetch installation and configuration
- Automatic reboot after installation

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/Baanaaana/pi-setup/main/pi_setup.sh -o pi_setup.sh && sudo bash pi_setup.sh && rm pi_setup.sh
```

## What The Script Does

The script performs these steps in order:

1. System Updates:
   - Updates package lists
   - Performs system upgrade with dist-upgrade
   - Performs regular upgrade
   - Removes unnecessary packages

2. Automatic Updates Configuration:
   - Installs unattended-upgrades and apt-listchanges
   - Configures automatic security updates
   - Sets up daily update checks and installations
   - Configures update sources (Debian, Raspbian, Raspberry Pi Foundation)
   - Enables automatic removal of unused packages
   - Disables automatic reboot (manual control maintained)

3. VNC Server Setup:
   - Installs RealVNC server package
   - Enables VNC service using raspi-config
   - Configures VNC for remote access

4. Bash Configuration:
   - Creates .bashrc if it doesn't exist
   - Adds useful aliases
   - Configures terminal appearance
   - Sets up command shortcuts

5. Fastfetch Installation:
   - Installs fastfetch package
   - Configures it to run at SSH login
   - Shows system information on login

6. Final Steps:
   - 10-second countdown to reboot
   - Option to cancel reboot with Ctrl+C
   - Automatic system reboot

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

# start fastfetch at SSH login
fastfetch
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
  - Automatic security updates will be running in the background
  - System will check for and install updates daily

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


## macOS SD Card Formatter

A utility script for macOS to format SD cards with options for quick or secure formatting. Useful for preparing SD cards before flashing Raspberry Pi OS.

### Features

- Interactive disk selection with safety checks
- Prevents formatting of internal/system disks
- Two formatting modes:
  - **Quick Format**: Fast FAT32 formatting (recommended)
  - **Secure Erase**: Overwrites entire card with zeros before formatting (for security/privacy)
- Color-coded output for clear feedback
- Multiple confirmation prompts to prevent accidents
- Safe disk ejection after formatting

### Usage

```bash
# Download and run
curl -sSL https://raw.githubusercontent.com/Baanaaana/pi-setup/main/macos_sd_format.sh -o macos_sd_format.sh && sudo bash macos_sd_format.sh && rm macos_sd_format.sh

# Or run locally
sudo bash macos_sd_format.sh
```

### Important Notes

- **macOS only**: This script is designed specifically for macOS
- **Requires sudo**: Must be run with administrator privileges
- **Destructive operation**: ALL data on the selected disk will be erased
- **External disks only**: The script will not format internal disks
- **Secure erase is slow**: Can take 30+ minutes depending on card size

### What The Script Does

1. Verifies macOS environment and sudo privileges
2. Scans and lists all external disks
3. Allows interactive selection of target disk
4. Displays detailed disk information
5. Requires explicit confirmation (type "YES")
6. Offers choice between quick format or secure erase
7. Unmounts the selected disk
8. Formats as FAT32 (MBR partition scheme)
9. Safely ejects the disk

### Format Options

**Quick Format:**
- Fast operation (usually under 1 minute)
- Creates new FAT32 file system
- Recommended for most users
- Good for preparing cards for Raspberry Pi Imager

**Secure Erase:**
- Slow operation (30+ minutes)
- Overwrites entire disk with zeros
- Then formats as FAT32
- Better for security/privacy concerns
- Use when disposing of cards or reusing cards with sensitive data

## PiOSK Chromium fix

```bash
curl -sSL https://raw.githubusercontent.com/Baanaaana/pi-setup/main/piosk_chromium_fix.sh -o pi_setup.sh && sudo bash pi_setup.sh && rm pi_setup.sh
```