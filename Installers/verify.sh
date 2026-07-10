#!/bin/bash
#
# SIDStation
# verify.sh
#
# Verifica a instalação do SIDStation
#

LOGFILE="/var/log/sidstation-verify.log"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

PASS=0
FAIL=0
WARN=0

mkdir -p /var/log
touch "$LOGFILE"

log()
{
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOGFILE"
}

check()
{
    NAME="$1"
    CMD="$2"

    printf "%-40s" "$NAME"

    if eval "$CMD" >/dev/null 2>&1
    then
        echo -e "${GREEN}PASS${NC}"
        log "$NAME PASS"
        PASS=$((PASS+1))
    else
        echo -e "${RED}FAIL${NC}"
        log "$NAME FAIL"
        FAIL=$((FAIL+1))
    fi
}

warning()
{
    echo -e "${YELLOW}$1${NC}"
    log "$1"
    WARN=$((WARN+1))
}

echo
echo "===================================================="
echo "          SIDStation Verification Tool"
echo "===================================================="
echo

#########################################################
# Operating System
#########################################################

check "Operating System" \
"grep -qi bookworm /etc/os-release"

#########################################################
# Architecture
#########################################################

check "64-bit Architecture" \
"uname -m | grep -Eq 'aarch64|arm64'"

#########################################################
# Internet
#########################################################

check "Internet Connection" \
"ping -c 1 github.com"

#########################################################
# Python
#########################################################

check "Python 3" \
"python3 --version"

#########################################################
# Pip
#########################################################

check "PIP" \
"pip3 --version"

#########################################################
# Python Modules
#########################################################

check "NumPy" \
"python3 -c 'import numpy'"

check "SciPy" \
"python3 -c 'import scipy'"

check "PyYAML" \
"python3 -c 'import yaml'"

check "Loguru" \
"python3 -c 'import loguru'"

check "InfluxDB Client" \
"python3 -c 'import influxdb_client'"

check "PyFFTW" \
"python3 -c 'import pyfftw'"

#########################################################
# SDRplay API
#########################################################

check "SDRplay API" \
"ldconfig -p | grep libsdrplay_api"

#########################################################
# SoapySDR
#########################################################

check "SoapySDR" \
"SoapySDRUtil --info"

#########################################################
# SDRplay Driver
#########################################################

check "SoapySDRPlay Module" \
"SoapySDRUtil --find | grep -qi sdrplay"

#########################################################
# Detect Receiver
#########################################################

printf "%-40s" "RSP2 Detection"

DEVICE=$(SoapySDRUtil --find 2>/dev/null)

if echo "$DEVICE" | grep -qi sdrplay
then
    echo -e "${GREEN}PASS${NC}"
    PASS=$((PASS+1))

    echo
    echo "Detected device:"
    echo "$DEVICE"
    echo

else
    echo -e "${RED}FAIL${NC}"
    FAIL=$((FAIL+1))
fi

#########################################################
# InfluxDB
#########################################################

check "InfluxDB Service" \
"systemctl is-active influxdb"

#########################################################
# Grafana
#########################################################

check "Grafana Service" \
"systemctl is-active grafana-server"

#########################################################
# HTTP Test
#########################################################

check "InfluxDB HTTP" \
"curl -s http://localhost:8086"

check "Grafana HTTP" \
"curl -s http://localhost:3000"

#########################################################
# systemd
#########################################################

check "SIDStation Service" \
"systemctl status sidstation"

#########################################################
# Disk
#########################################################

FREE=$(df --output=avail / | tail -1)

if [ "$FREE" -lt 5242880 ]
then
    warning "Less than 5 GB available."
fi

#########################################################
# Memory
#########################################################

MEM=$(free -m | awk '/Mem:/ {print $7}')

if [ "$MEM" -lt 500 ]
then
    warning "Low available memory."
fi

#########################################################
# CPU Temperature
#########################################################

if command -v vcgencmd >/dev/null
then

TEMP=$(vcgencmd measure_temp)

echo
echo "CPU Temperature"

echo "$TEMP"

fi

#########################################################
# Summary
#########################################################

echo
echo "===================================================="

echo "Verification Summary"

echo "===================================================="

echo

echo "PASS : $PASS"

echo "FAIL : $FAIL"

echo "WARN : $WARN"

echo

if [ "$FAIL" -eq 0 ]
then
    echo -e "${GREEN}SIDStation installation verified successfully.${NC}"
else
    echo -e "${RED}Some components require attention.${NC}"
fi

echo
echo "Verification log:"
echo "$LOGFILE"

echo
exit 0