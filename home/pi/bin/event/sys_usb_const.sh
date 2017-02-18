#!bin/bash
#logpath=${0%/*}/log.txt

if test "${pgpath-UNDEF}" = "UNDEF"; then   #(1)
  if test "$pgpath" = ""; then              #(2)
    
    pgpath=${0%/*}/
  fi
fi
if test -e ${0%/*}/pgpath;
then
 pgpath=$(cat ${0%/*}/pgpath)
fi
lockfile=${0%/*}/mylock

export pgpath

function log() {
#echo "$(date) $1" >> ${0%/*}/log
echo "$(date) $1" >> ${0%/*}/log
}

