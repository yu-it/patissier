#!/bin/bash
. ${0%/*}/sys_usb_const.sh
ip=$1
errcd=$2
log "start validate"
while test "$ip" != ""
do
	ping "$ip" -c 3
	if test "$?" = "0";
	then
		log "--network errorlevel:$errcd"
		exit $errcd
	fi
	shift 2
	ip=$1
	errcd=$2
done
log "--network errorlevel:unknown"
exit 9