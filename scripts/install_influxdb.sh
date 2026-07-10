#!/bin/bash
#
# SIDStation
# install_influxdb.sh
#

set -e

##############################################
# Configuration
##############################################

LOGFILE="/var/log/sidstation-install.log"

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
    echo -e "${GREEN}[ OK ]${NC} $1"
    log "[OK] $1"
}

warn(){
    echo -e "${YELLOW}[WARN]${NC} $1"
    log "[WARN] $1"
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
    echo "Run this script with sudo."
    exit 1
fi

##############################################
# Already Installed?
##############################################

if command -v influxd >/dev/null 2>&1
then

    ok "InfluxDB already installed."

else

    ##########################################
    # Add Repository
    ##########################################

    info "Adding InfluxData repository..."

    mkdir -p /etc/apt/keyrings

    if [ ! -f /etc/apt/keyrings/influxdata-archive.key ]; then

        wget -qO- https://repos.influxdata.com/influxdata-archive_compat.key \
        | gpg --dearmor \
        | tee /etc/apt/keyrings/influxdata-archive.key >/dev/null

    fi

    echo "deb [signed-by=/etc/apt/keyrings/influxdata-archive.key] \
https://repos.influxdata.com/debian stable main" \
> /etc/apt/sources.list.d/influxdata.list

    ##########################################

    apt update

    ##########################################

    info "Installing InfluxDB..."

    apt install -y influxdb2

    ok "InfluxDB installed."

fi

##############################################
# Enable Service
##############################################

info "Enabling service..."

systemctl enable influxdb

##############################################
# Start Service
##############################################

info "Starting service..."

systemctl restart influxdb

##############################################
# Wait Startup
##############################################

echo

echo "Waiting for InfluxDB..."

for i in {1..30}
do

    if curl -s http://localhost:8086/health >/dev/null
    then
        break
    fi

    sleep 1

done

##############################################
# Verify
##############################################

echo

if curl -s http://localhost:8086/health >/dev/null
then

    ok "InfluxDB is running."

else

    fail "InfluxDB did not start."

fi

##############################################
# Version
##############################################

echo
echo "======================================"

echo "InfluxDB Version"

echo "======================================"

influxd version || true

##############################################
# First Setup
##############################################

echo
echo "======================================"

echo "FIRST CONFIGURATION REQUIRED"

echo "======================================"
echo

if influx setup --help >/dev/null 2>&1
then

cat << EOF

Run the following command once:

sudo influx setup

Suggested values:

Organization:

SIDStation

Bucket:

sid_data

Retention:

0 (Forever)

EOF

else

warn "Influx CLI not found."

fi

##############################################

echo
echo "Web Interface"

echo

echo "http://localhost:8086"

echo

ok "InfluxDB installation completed."

exit 0