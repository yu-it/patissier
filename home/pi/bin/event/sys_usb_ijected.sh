#!bin/bash
. ${0%/*}/sys_usb_const.sh
log "ijected at $1" 
rm -f $lockfile
