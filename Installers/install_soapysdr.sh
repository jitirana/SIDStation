#!/bin/bash
#
# SIDStation
# SoapySDR + SoapySDRPlay Installer
#

set -e

WORKDIR=/tmp/sidstation-build

mkdir -p "$WORKDIR"

echo "======================================"
echo " Installing SoapySDR"
echo "======================================"

#
# Install packages
#
sudo apt update

sudo apt install -y \
git \
cmake \
g++ \
make \
pkg-config \
libusb-1.0-0-dev

#
# SoapySDR
#

if SoapySDRUtil --info >/dev/null 2>&1; then
    echo "[OK] SoapySDR already installed."
else

    cd "$WORKDIR"

    rm -rf SoapySDR

    git clone https://github.com/pothosware/SoapySDR.git

    cd SoapySDR

    mkdir build

    cd build

    cmake ..

    make -j$(nproc)

    sudo make install

    sudo ldconfig

fi

#
# SoapySDRPlay
#

if SoapySDRUtil --find 2>/dev/null | grep -qi sdrplay; then

    echo "[OK] SDRplay module already installed."

else

    cd "$WORKDIR"

    rm -rf SoapySDRPlay3

    git clone https://github.com/pothosware/SoapySDRPlay3.git

    cd SoapySDRPlay3

    mkdir build

    cd build

    cmake ..

    make -j$(nproc)

    sudo make install

    sudo ldconfig

fi

echo

echo "Testing installation..."

echo

SoapySDRUtil --info

echo

echo "Searching for SDR devices..."

echo

SoapySDRUtil --find || true

echo

echo "Installed modules"

SoapySDRUtil --probe="driver=sdrplay" || true

echo

echo "[OK] Installation completed."
