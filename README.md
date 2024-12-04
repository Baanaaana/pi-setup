# Raspberry Pi Setup Script

A simple bash script to customize your Raspberry Pi's terminal configuration. This script modifies your `.bashrc` file to add useful aliases and configurations.

## Features

The script will:
- Add an `update` alias for easy system updates
- Clear the default terminal message
- Add a blank line for better readability
- Install and configure neofetch to display system information at login
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
alias update='sudo -- sh -c "apt update && apt upgrade"'

# add blank line
echo ""

# clear default message
clear

# start neofetch at SSH login
neofetch
```

## Requirements

- Raspberry Pi running Raspberry Pi OS (or other Debian-based Linux)
- Internet connection (for installing neofetch if not present)
- Basic terminal access

## After Installation

After running the script, either:
- Restart your terminal
- Or run `source ~/.bashrc` to apply changes immediately

## License

This project is open source and available under the [MIT License](LICENSE).
