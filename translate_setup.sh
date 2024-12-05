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

# Install required packages
echo "Installing required packages..."
sudo apt update
sudo apt install -y python3-pip git python3-pyaudio flac python3-venv python3-full

# Clone PiTranslate repository
echo "Cloning PiTranslate repository..."
cd ~
rm -rf PiTranslate
git clone https://github.com/dconroy/PiTranslate.git
cd PiTranslate

# Create and activate virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python requirements
echo "Installing Python packages..."
pip3 install SpeechRecognition gTTS watchdog

# Create webpage directory and set permissions
echo "Creating webpage..."
sudo mkdir -p /var/www/html/translate
sudo chown -R www-data:www-data /var/www/html/translate
sudo chmod -R 755 /var/www/html/translate

# Create HTML file for displaying translations
sudo tee /var/www/html/translate/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Translation Display</title>
    <meta charset="UTF-8">
    <style>
        body {
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: #000;
            color: #fff;
            font-family: Arial, sans-serif;
        }
        #translation {
            font-size: 48px;
            text-align: center;
            max-width: 760px;
            word-wrap: break-word;
        }
    </style>
    <script>
        function updateTranslation() {
            fetch('translation.txt')
                .then(response => response.text())
                .then(text => {
                    document.getElementById('translation').innerText = text;
                });
            setTimeout(updateTranslation, 1000);
        }
        window.onload = updateTranslation;
    </script>
</head>
<body>
    <div id="translation">Waiting for translation...</div>
</body>
</html>
EOF

# Create initial translation file
sudo touch /var/www/html/translate/translation.txt
sudo chown www-data:www-data /var/www/html/translate/translation.txt
sudo chmod 644 /var/www/html/translate/translation.txt

# Create script to update translations
cat > ~/PiTranslate/update_display.py << 'EOF'
import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

TRANSLATION_FILE = "translation.txt"
DISPLAY_FILE = "/var/www/html/translate/translation.txt"

class TranslationHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path.endswith(TRANSLATION_FILE):
            with open(TRANSLATION_FILE, 'r') as f:
                translation = f.read()
            with open(DISPLAY_FILE, 'w') as f:
                f.write(translation)

def main():
    # Create initial empty file
    with open(DISPLAY_FILE, 'w') as f:
        f.write("Waiting for translation...")

    event_handler = TranslationHandler()
    observer = Observer()
    observer.schedule(event_handler, path='.', recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

if __name__ == "__main__":
    main()
EOF

# Install lightweight web server
sudo apt install -y lighttpd
sudo systemctl enable lighttpd
sudo systemctl start lighttpd

# Configure lighttpd
sudo tee /etc/lighttpd/conf-enabled/10-translate.conf << EOF
server.document-root = "/var/www/html"
dir-listing.activate = "disable"
EOF

sudo systemctl restart lighttpd

# Create service file for translation display
sudo tee /etc/systemd/system/translation-display.service << EOF
[Unit]
Description=Translation Display Service
After=network.target

[Service]
ExecStart=/home/pi/PiTranslate/venv/bin/python3 /home/pi/PiTranslate/update_display.py
WorkingDirectory=/home/pi/PiTranslate
User=$USER
Restart=always
Environment=PATH=/home/pi/PiTranslate/venv/bin:$PATH

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable translation-display
sudo systemctl start translation-display

# Create desktop shortcut
echo "Creating desktop shortcut..."
mkdir -p ~/Desktop
cat > ~/Desktop/Translation-Display.desktop << EOF
[Desktop Entry]
Type=Application
Name=Translation Display
Comment=Open Translation Display Webpage
Exec=chromium-browser --start-fullscreen --kiosk http://localhost/translate
Icon=web-browser
Terminal=false
Categories=Utility;
EOF

# Make the desktop shortcut executable
chmod +x ~/Desktop/Translation-Display.desktop

echo "Installation complete!"
echo "Access the translation display at: http://localhost/translate"
echo "Or double-click the 'Translation Display' shortcut on your desktop"
echo "The webpage is optimized for 800x480 display" 