#!/bin/bash
#
# SIDStation
# install_grafana.sh
#
# Instala o Grafana OSS no Raspberry Pi
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

log() {
    echo "$(date '+%F %T') $1" | tee -a "$LOGFILE"
}

info() {
    echo -e "${BLUE}==>${NC} $1"
    log "$1"
}

ok() {
    echo -e "${GREEN}[ OK ]${NC} $1"
    log "[OK] $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    log "[WARN] $1"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    log "[FAIL] $1"
    exit 1
}

##############################################
# Root
##############################################

if [ "$EUID" -ne 0 ]; then
    echo
    echo "Run this script with sudo."
    echo
    exit 1
fi

##############################################
# Already Installed?
##############################################

if command -v grafana-server >/dev/null 2>&1
then
    ok "Grafana already installed."

else

    ##########################################
    # Install prerequisites
    ##########################################

    info "Installing prerequisites..."

    apt update

    apt install -y \
        apt-transport-https \
        software-properties-common \
        wget \
        curl \
        gnupg

    ##########################################
    # Import GPG Key
    ##########################################

    info "Adding Grafana repository..."

    mkdir -p /etc/apt/keyrings

    if [ ! -f /etc/apt/keyrings/grafana.gpg ]
    then
        wget -q -O - https://apt.grafana.com/gpg.key \
            | gpg --dearmor \
            | tee /etc/apt/keyrings/grafana.gpg >/dev/null
    fi

    ##########################################
    # Repository
    ##########################################

    cat >/etc/apt/sources.list.d/grafana.list <<EOF
deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main
EOF

    ##########################################

    apt update

    ##########################################

    info "Installing Grafana OSS..."

    apt install -y grafana

    ok "Grafana installed."

fi

##############################################
# Enable Service
##############################################

info "Enabling Grafana service..."

systemctl enable grafana-server

##############################################
# Start Service
##############################################

info "Starting Grafana..."

systemctl restart grafana-server

##############################################
# Wait Startup
##############################################

echo
echo "Waiting for Grafana..."

for i in {1..30}
do
    if curl -s http://localhost:3000/api/health >/dev/null
    then
        break
    fi

    sleep 1
done

##############################################
# Verify
##############################################

echo

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/login)

if [ "$HTTP_CODE" = "200" ]
then
    ok "Grafana is running."
else
    fail "Grafana failed to start."
fi

##############################################
# Version
##############################################

echo
echo "======================================"
echo "Grafana Version"
echo "======================================"

grafana-server -v || true

##############################################
# Firewall
##############################################

if command -v ufw >/dev/null 2>&1
then

    if ufw status | grep -q "Status: active"
    then

        warn "UFW detected."

        echo
        echo "If remote access is required:"
        echo
        echo "sudo ufw allow 3000/tcp"
        echo

    fi

fi

##############################################
# Finish
##############################################

echo
echo "======================================"
echo "Grafana Installation Complete"
echo "======================================"
echo

echo "URL:"
echo "http://<raspberry-ip>:3000"
echo

echo "Default Credentials:"
echo
echo "Username: admin"
echo "Password: admin"
echo

echo "Grafana will ask you to change the password"
echo "during the first login."
echo

ok "Installation completed successfully."

exit 0