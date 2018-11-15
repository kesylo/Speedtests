#!/bin/sh
## Simple WIFI command line connector 
## Usage: 
## sudo ./wifiConnector.sh <SSID> <PASSWORD>

## Usage message
display_usage() {
echo "This script must be run with super-user privileges and receive 1 argument."
echo "eg: sudo ./wifiConnector.sh 0 or 1"
exit 1
}

## Check if root access
if [ "$(id -u)" != "0" ]; then
display_usage
fi

## Check if user gives enough parameters
if [ "$#" -ne 1 ]; then
display_usage
fi

ssid1="FAMOCO"
ssid2="FAMOCO-5Ghz"
pass="famocoaccess"
priority1=1
priority2=2


if [ $1 = "0" ]
then
#connect to 5
cat <<EOT > /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BE

network={
	ssid="$ssid2"
	psk="$pass"
	priority=$priority2
}

network={
	ssid="$ssid1"
	psk="$pass"
	priority=$priority1
	key_mgmt=WPA-PSK
}
EOT

systemctl restart dhcpcd

elif [ $1 = "1" ]
then
#connect to 2.4
cat <<EOT > /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BE

network={
	ssid="$ssid1"
	psk="$pass"
	priority=$priority2
	key_mgmt=WPA-PSK
}

network={
	ssid="$ssid2"
	psk="$pass"
	priority=$priority1
}
EOT

systemctl restart dhcpcd
fi
