#!/bin/bash
export PATH=$PATH:/bin:/sbin:/usr/local/bin:/usr/local/sbin
INTERFACE="wlan0"
AP_BSSID=""
CH=""
CH_RNG='\b([1-9]|1[0-2])\b'
OF="crack"

if [ "$EUID" -ne 0 ]
    then echo "Please run as super user"
    exit
fi

help(){
	echo "Brute Force Hacking Helper Script";
	echo "Options:"
	echo "s - Scans everything";
	echo "i - Sets scanning wireless interface";
	echo "c - Sets scanning channel"
	echo "b - Sets AP_BSSID for Filtering";
	echo "f - Scans devices with BSSID filtering"
	echo "w - Scans and saves frames. Required BSSID"
	1>&2; exit 1;
}

scan(){
	airmon-ng start $INTERFACE;
	airmon-ng check kill;
	airodump-ng $INTERFACE;
}

scan_target(){
	if [[ $CH =~ $CH_RNG ]]; then
		airodump-ng --bssid $AP_BSSID --channel $CH $INTERFACE;
	else
		airodump-ng --bssid $AP_BSSID $INTERFACE;
	fi
}

get_target_frames(){
	if [[ $CH =~ $CH_RNG ]]; then
		airodump-ng --bssid $AP_BSSID --channel $CH --write $OF $INTERFACE;
	else
		airodump-ng --bssid $AP_BSSID --write $OF $INTERFACE;
	fi
}

while getopts "hsi:c:b:fw" opt; do
    case "${opt}" in
    h)
        help
        exit 1;
        ;;
    s) 	scan;
        exit 1;
        ;;
    i)	INTERFACE=${OPTARG}
	;;
    c)	CH=${OPTARG}
	;;
    b)	AP_BSSID=${OPTARG};
	;;
    f) 	scan_target;
        exit 1;
      	;;
    w)	get_target_frames;
	exit 1;
	;;

    esac
done

if [ $opt =  ? ]; then
	help;
	1>&2; exit 1;
fi
