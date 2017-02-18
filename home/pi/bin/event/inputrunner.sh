#!/bin/bash
#test function of comment, "last"file function
#test exitX

. ${0%/*}/sys_usb_const.sh
led_trigger=/sys/class/leds/led0/trigger
led_swt=/sys/class/leds/led0/brightness
function init_led() {
 echo none > /sys/class/leds/led0/trigger
}

function led_on() {
 echo none > /sys/class/leds/led0/trigger
 echo 1 > /sys/class/leds/led0/brightness
}

function led_off() {
 echo none > /sys/class/leds/led0/trigger
 echo 0 > /sys/class/leds/led0/brightness
}

function led_tick() {
 led_off
 sleep 0.05
 led_on
 sleep 0.05
}
function led_tack() {
 led_off
 sleep 0.5
 led_on
 sleep 0.5
}

function exit_sh() {
	log "start exit! $(cat $pgpath/elv)"
	lv=$(cat $pgpath/elv)

	if test $lv -gt 10;
	then
		lv=10
	fi
	
	for ((i=0; i < $lv; i++)); do
		log "tick!"
		led_tack
	done
	if test -e $pgpath/elv;
	then
	 sudo rm -f $pgpath/elv
	fi
	led_on
	rm $pgpath/elv
	unlink ${0%/*}/log
	unlink ${0%/*}/std
	rm ${0%/*}/pgpath
	unlink $pgpath/log
	unlink $pgpath/std
	exit $lv

}
function built_in() {
log "built-in $1"
 case $1 in
  @validate*)
  log  $(echo "validate--$1")
  log "$(echo "sudo bash ${0%/*}/validate_nw.sh ${1##@validate}") "
  $(echo "sudo bash ${0%/*}/validate_nw.sh ${1##@validate}") 
  echo $? > $pgpath/elv
  ;;
  @network*)
   log "config network"
   $(echo "sudo bash ${0%/*}/ifsetup.sh ${1##@network}")
   #$(echo "$1" | sed "s/@network/bash ${0%/*}/ifsetup\.sh/")
   echo $? > $pgpath/elv
  ;;
  @set*)
  echo $(echo "$1" | cut -c5) > $pgpath/elv
  log "set--$(echo "$1" | cut -c5)"
  ;;
  @next*)
  log "next"
  ;;
  @exit*)
  log "exit--"
  echo $(echo "$1" | cut -c6) > $pgpath/elv
  exit_sh
  ;;
  @reboot*)
  log "reboot--start"
  sudo reboot
  ;;
  @shutdown*)
  log "shutdown--start"
  sudo shutdown -h 0
  ;;
  @*)
   log "unkown built-in-function"
  ;;
 esac


}
function exec() {
stmt=$(echo "$1" | cut -c2-)
log "stmt:$stmt"
case $stmt in 
 @*)
  built_in "$stmt"
 ;;
 *)
  log "exec command:$stmt"
  eval ${stmt}
  echo $? > $pgpath/elv
 ;;
esac

}

#main process
log "patissier start cd is $(pwd)"
init_led
for ((i=0; i < 30; i++)); do
	log "tick!"
	led_tick
done
led_off

if test -e $pgpath/elv;
then
 sudo rm -f $pgpath/elv
fi
specfile=$1
log "--show input..."
log "$(cat $specfile)"
log "--end"
B_IFS=$IFS
log "aaa"
cat $specfile | while read line
do
 cd "$pgpath"
 log "---line---"
 log "$line"
 first=$(echo $line | cut -c 1)
 case $line in
  \?*)
   log "exec any command"
   exec "$line"
   
   echo "d" > $pgpath/last
  ;;
  [0-9]*)
  elv=$(cat $pgpath/elv)
  log "errorLv $first : $elv"
   #if file "last" is 'd' then haven't done
   if test $first = $elv -a  "$(cat $pgpath/last)" = "d";
   then
    log "exec $(echo "$line" | cut -c2-)"
    exec "$line"
    #to explain that process have been done, write "e" to file'last'
    echo "e" > $pgpath/last
   fi
  ;;
  --*)
  log "comment, skip:$line"
  ;;
  *)
   echo "d" > $pgpath/last
  log unexpected pattern $line
  ;;
 esac
 log "---line end---"
 log "$line"
 for ((i=0; i < 3; i++)); do
  log "tick!"
  led_tick
 done
 led_off
 sleep 0.5
done
IFS=$B_IFS
exit_sh
