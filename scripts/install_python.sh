#!/bin/bash
#
# SIDStation
# install_python.sh
#
# Creates the Python virtual environment and installs
# all required Python packages.
#

set -e

##############################################
# Configuration
##############################################

INSTALL_DIR="/opt/sidstation"
VENV_DIR="$INSTALL_DIR/venv"
LOGFILE="/var/log/sidstation-install.log"

##############################################
# Colors
##############################################

GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

##############################################

log(){
    echo "$(date '+%F %T') $1" | tee -a "$LOGFILE"
}

info(){
    echo -e "${BLUE}==>${NC} $1"
    log "$1"
}

ok(){
    echo -e "${GREEN}[OK]${NC} $1"
    log "[OK] $1"
}

fail(){
    echo -e "${RED}[FAIL]${NC} $1"
    log "[FAIL] $1"
    exit 1
}

##############################################
# Root
##############################################

if [ "$EUID" -ne 0 ]; then
    echo "Run with sudo."
    exit 1
fi

##############################################
# Python
##############################################

command -v python3 >/dev/null || fail "Python3 not installed"

command -v pip3 >/dev/null || fail "pip3 not installed"

##############################################
# Create installation directory
##############################################

mkdir -p "$INSTALL_DIR"

##############################################
# Create virtual environment
##############################################

if [ -d "$VENV_DIR" ]; then

    ok "Virtual environment already exists."

else

    info "Creating virtual environment..."

    python3 -m venv "$VENV_DIR"

    ok "Virtual environment created."

fi

##############################################
# Activate
##############################################

source "$VENV_DIR/bin/activate"

##############################################
# Upgrade pip
##############################################

info "Updating pip..."

pip install --upgrade pip setuptools wheel

##############################################
# Install packages
##############################################

PACKAGES=(

numpy

scipy

pyfftw

matplotlib

PyYAML

requests

psutil

click

rich

loguru

influxdb-client

SoapySDR

)

for pkg in "${PACKAGES[@]}"
do

    if pip show "$pkg" >/dev/null 2>&1
    then

        ok "$pkg already installed."

    else

        info "Installing $pkg..."

        pip install "$pkg"

        ok "$pkg installed."

    fi

done

##############################################
# Test imports
##############################################

echo
echo "======================================"
echo "Testing Python packages..."
echo "======================================"

python << EOF

modules = [

"numpy",

"scipy",

"pyfftw",

"yaml",

"requests",

"psutil",

"click",

"rich",

"loguru",

"influxdb_client",

"SoapySDR"

]

failed = False

for module in modules:

    try:

        __import__(module)

        print(f"{module:20} PASS")

    except Exception as e:

        print(f"{module:20} FAIL ({e})")

        failed = True

if failed:

    raise SystemExit(1)

EOF

##############################################
# Version Information
##############################################

echo
echo "======================================"
echo "Python Version"
echo "======================================"

python --version

echo
echo "PIP Version"

pip --version

echo
echo "Installed packages"

pip list

##############################################
# Finished
##############################################

deactivate

echo
echo "======================================"

ok "Python environment installed successfully."

echo "Virtual Environment: $VENV_DIR"

echo "======================================"

exit 0