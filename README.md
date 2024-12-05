# Raspberry Pi Setup Scripts

A collection of scripts to customize your Raspberry Pi's configuration.

## Pi Setup Script

A script to customize your Raspberry Pi's terminal configuration. This script modifies your `.bashrc` file to add useful aliases and configurations.

### Features

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
- Optional reboot after installation

## Translation Display Script

A script to install and configure PiTranslate with a local webpage display. This script sets up a live translation tool with a display optimized for 800x480 screens.

### Features

The script will:
- Install PiTranslate and its dependencies
- Create a local webpage for displaying translations
- Set up a lightweight web server
- Create a desktop shortcut for easy access
- Configure automatic service startup
- Optimize display for 800x480 resolution

### Quick Installation

Run these commands:

```bash
curl -O https://raw.githubusercontent.com/Baanaaana/pi-setup/main/translate_setup.sh && chmod +x translate_setup.sh && ./translate_setup.sh
```

### Manual Installation

1. Download the script:

```bash
curl -O https://raw.githubusercontent.com/Baanaaana/pi-setup/main/translate_setup.sh
```

2. Make it executable:

```bash
chmod +x translate_setup.sh
```

3. Run the script:

```bash
./translate_setup.sh
```

### After Installation

- Access the translation display at: http://localhost/translate
- Double-click the 'Translation Display' shortcut on your desktop
- The webpage will automatically update with new translations
- Display is optimized for 800x480 screens

### Requirements

- Raspberry Pi running Raspberry Pi OS
- Internet connection
- Python 3
- Microphone for speech input
- Web browser (Chromium recommended)
