#!/bin/bash
#
# SIDStation
# install_dependencies.sh
#
# Instala todas as dependências básicas do sistema.
#

set -e

LOGFILE="/var/log/sidstation-install.log"

#----------------------------------------------------------
# Colors
#----------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

#----------------------------------------------------------
# Logging
#----------------------------------------------------------

log()
{
    echo "$(date '+%Y-%m-%d %H:%M:%S')  $1" | tee -a "$LOGFILE"
}

success()
{
    echo -e "${GREEN}[ OK ]${NC} $1"
    log "[OK] $1"
}

warning()
{
    echo -e "${YELLOW}[WARN]${NC} $1"
    log "[WARN] $1"
}

error()
{
    echo -e "${RED}[FAIL]${NC} $1"
    log "[FAIL] $1"
    exit 1
}

info()
{
    echo -e "${BLUE}==>${NC} $1"
    log "$1"
}

#----------------------------------------------------------
# Root
#----------------------------------------------------------

if [ "$EUID" -ne 0 ]; then
    echo
    echo "Run this script as root:"
    echo
    echo "sudo ./install_dependencies.sh"
    echo
    exit 1
fi

mkdir -p /var/log
touch "$LOGFILE"

echo
echo "=============================================="
echo " SIDStation Dependency Installer"
echo "=============================================="
echo

#----------------------------------------------------------
# Check Internet
#----------------------------------------------------------

info "Checking Internet connectivity..."

if ping -c 2 github.com >/dev/null 2>&1 ; then
    success "Internet connection OK"
else
    error "No Internet connection."
fi

#----------------------------------------------------------
# Update repositories
#----------------------------------------------------------

info "Updating package repositories..."

apt update

success "Repository updated"

#----------------------------------------------------------
# Upgrade
#----------------------------------------------------------

info "Upgrading installed packages..."

apt -y upgrade

success "System updated"

#----------------------------------------------------------
# Package List
#----------------------------------------------------------

PACKAGES=(

git

wget

curl

unzip

build-essential

cmake

make

gcc

g++

pkg-config

software-properties-common

apt-transport-https

ca-certificates

gnupg

lsb-release

libusb-1.0-0-dev

libfftw3-dev

libfftw3-bin

libfftw3-single3

libfftw3-long3

libfftw3-quad3

python3

python3-dev

python3-pip

python3-venv

python3-setuptools

python3-wheel

python3-numpy

python3-scipy

python3-yaml

python3-requests

python3-psutil

python3-matplotlib

python3-click

python3-rich

)

#----------------------------------------------------------
# Install Packages
#----------------------------------------------------------

echo
echo "Installing packages..."
echo

for pkg in "${PACKAGES[@]}"
do

    if dpkg -s "$pkg" >/dev/null 2>&1
    then

        success "$pkg already installed"

    else

        info "Installing $pkg..."

        apt install -y "$pkg"

        success "$pkg installed"

    fi

done

#----------------------------------------------------------
# Python pip packages
#----------------------------------------------------------

info "Installing Python packages..."

python3 -m pip install --upgrade pip

python3 -m pip install \
numpy \
scipy \
pyfftw \
influxdb-client \
loguru \
pyyaml \
requests \
psutil \
rich \
click

success "Python packages installed"

#----------------------------------------------------------
# Versions
#----------------------------------------------------------

echo
echo "=============================================="
echo " Installed Versions"
echo "=============================================="

echo
echo "Python:"
python3 --version

echo
echo "PIP:"
pip3 --version

echo
echo "GCC:"
gcc --version | head -1

echo
echo "CMake:"
cmake --version | head -1

echo
echo "Git:"
git --version

echo

#----------------------------------------------------------
# Finished
#----------------------------------------------------------

echo
echo "=============================================="
success "Dependency installation completed."
echo "=============================================="
echo

exit 0
