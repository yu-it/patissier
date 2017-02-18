#!bin/bash
. ${0%/*}/sys_usb_const.sh
if test ! -e $1/patissier;
then
 log "no process..."
 exit 
fi
log "doprocess"
if test -e $lockfile;
then
 log "state is locked. exit with no process."
fi
echo "0" > $lockfile
#pgpath=${0%/*}/../programs/stage
#rm -fR‚¾‚µ•|‚¢‚©‚çŒÅ’è‚ÅEEE
pgpath=/home/pi/bin/programs/stage
if -e $pgpath;
then
 sudo rm -fR $pgpath
fi
mkdir -p $pgpath
cp -rf $1/patissier/* $pgpath
sudo chown -R pi:pi $pgpath/*
if test -e $pgpath/recipe.txt;
then
 log "run recipe.txt"
 logpath=$1/patissier/$(date '+%y%m%d_%H%M%S').txt
 echo "logging start" >> $logpath

 sudo chmod 777 $logpath  >> "$logpath.std.txt" 2>&1

 if test -e ${0%/*}/log; then 
  if test ! -L ${0%/*}/log ; then
   sudo rm ${0%/*}/log
  else
   sudo unlink ${0%/*}/log
   sudo unlink ${0%/*}/std
  fi
 fi
 sudo ln -s $logpath ${0%/*}/log >> "$logpath.std.txt" 2>&1
 sudo ln -s $logpath.std.txt ${0%/*}/std >> "$logpath.std.txt" 2>&1
 sudo chmod 777 ${0%/*}/log  >> "$logpath.std.txt" 2>&1

 if test -e $pgpath/log; then 
  if test ! -L $pgpath/log ; then
   sudo rm $pgpath/log
  else
   sudo unlink $pgpath/log
   sudo unlink $pgpath/std
  fi
 fi
 sudo ln -s $logpath $pgpath/log >> "$logpath.std.txt" 2>&1
 sudo ln -s $logpath.std.txt $pgpath/std >> "$logpath.std.txt" 2>&1
 sudo chmod 777 $pgpath/log  >> "$logpath.std.txt" 2>&1

 echo "$pgpath" > ${0%/*}/pgpath

 cd $pgpath
 sudo service patissier start
fi
