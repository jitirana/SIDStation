#!/bin/bash

set -e

echo "======================================"
echo " SIDStation Installer v1.0"
echo "======================================"

sudo bash ../scripts/install_dependencies.sh
sudo bash ../scripts/install_sdrplay.sh
sudo bash ../scripts/install_soapysdr.sh
sudo bash ../scripts/install_python.sh
sudo bash ../scripts/install_influxdb.sh
sudo bash ../scripts/install_grafana.sh
sudo bash ../scripts/install_systemd.sh

echo
echo "Installation completed."

echo
echo "Running verification..."

sudo bash verify.sh
