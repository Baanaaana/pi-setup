#!/bin/bash

# PiOSK Chromium Fix Script
# Fixes "chromium-browser: command not found" error on newer Raspberry Pi OS

set -e

echo "=== PiOSK Chromium Fix Script ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Check if chromium is installed
echo "[1/4] Checking if chromium is installed..."
if ! command -v chromium &> /dev/null; then
    echo "Chromium is not installed. Installing now..."
    apt update
    apt install -y chromium
    echo "✓ Chromium installed successfully"
else
    echo "✓ Chromium is already installed"
fi

# Check if chromium-browser command exists
echo ""
echo "[2/4] Checking for chromium-browser command..."
if command -v chromium-browser &> /dev/null; then
    echo "✓ chromium-browser command already exists"
else
    echo "Creating symlink for chromium-browser..."
    ln -sf /usr/bin/chromium /usr/bin/chromium-browser
    echo "✓ Symlink created: /usr/bin/chromium-browser -> /usr/bin/chromium"
fi

# Restart piosk-runner service
echo ""
echo "[3/4] Restarting piosk-runner service..."
systemctl restart piosk-runner.service
sleep 2
echo "✓ Service restarted"

# Check service status
echo ""
echo "[4/4] Checking piosk-runner status..."
if systemctl is-active --quiet piosk-runner.service; then
    echo "✓ piosk-runner service is running"
    echo ""
    echo "=== SUCCESS ==="
    echo "PiOSK should now be displaying in kiosk mode!"
    echo ""
    echo "To view detailed status, run:"
    echo "  sudo systemctl status piosk-runner.service"
else
    echo "⚠ Warning: piosk-runner service may still be having issues"
    echo ""
    echo "Check logs with:"
    echo "  sudo journalctl -u piosk-runner -n 50"
fi

echo ""
echo "Dashboard is available at: http://$(hostname -I | awk '{print $1}')/"