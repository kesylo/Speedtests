#!/usr/bin/env bash

ssid1="FAMOCO"
ssid2="FAMOCO-5Ghz"
pass="famocoaccess"

## Usage
display_usage() {
echo "This script must be run with super-user privileges "
exit 1
}

# check if root
if [ "$(id -u)" != "0" ]; then
display_usage
fi

function turn_off_wifi(){
	wirelessname=`ls /sys/class/net | grep wlan* | head -1`
	ifconfig $wirelessname down
}

function turn_off_eth(){
	ethname=`ls /sys/class/net | grep eth* | head -1`
	ifconfig $ethname down
}

function turn_on_wifi(){
	wirelessname=`ls /sys/class/net | grep wlan* | head -1`
	ifconfig $wirelessname up
}

# Run on Ethernet
turn_off_wifi
sleep 5
./speedtest-Eth.sh

# Run on 5Ghz
./wificonnect.sh 0
sleep 10
echo $(iwgetid -r)
turn_off_eth
sleep 5
./speedtest-5ghz.sh

# Run on 2.4Ghz
./wificonnect.sh 1
sleep 10
echo $(iwgetid -r)
turn_off_eth
sleep 5
./speedtest-2ghz.sh

# Restart dhcpd
systemctl restart dhcpcd

