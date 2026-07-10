#!/bin/bash
#
# SIDStation
# SDRplay API Installer
#

set -e

INSTALLER_DIR="$(cd "$(dirname "$0")"/../installers && pwd)"

echo "======================================"
echo " Installing SDRplay API"
echo "======================================"

#
# Check if already installed
#
if ldconfig -p | grep -q libsdrplay_api; then
    echo "[OK] SDRplay API already installed."
    exit 0
fi

#
# Search installer
#
INSTALLER=$(find "$INSTALLER_DIR" -maxdepth 1 -type f -name "SDRplay_RSP_API*.run" | head -n1)

if [ -z "$INSTALLER" ]; then
    echo
    echo "ERROR:"
    echo
    echo "SDRplay installer not found."
    echo
    echo "Please download the Linux API from:"
    echo
    echo "https://www.sdrplay.com/downloads/"
    echo
    echo "Copy it to:"
    echo
    echo "$INSTALLER_DIR"
    echo
    exit 1
fi

echo
echo "Installer found:"
echo "$INSTALLER"

chmod +x "$INSTALLER"

echo
echo "Running installer..."
echo

sudo "$INSTALLER"

echo

echo "Updating linker cache..."

sudo ldconfig

echo

if ldconfig -p | grep -q libsdrplay_api; then
    echo "[OK] SDRplay API installed successfully."
else
    echo "[ERROR] SDRplay API installation failed."
    exit 1
fi
