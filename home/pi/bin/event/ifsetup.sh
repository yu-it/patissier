#!bin/bash
. ${0%/*}/sys_usb_const.sh
tmpfile=${0%/*}/tmp
###########################
#ifsetup.sh
#
#case ethernet
#ifsetup e(fixed) [s(fixed, mean "static")|d(fixed, mean "dhcp")] ip(xxx.xxx.xxx.xxx) mask(xxx.xxx.xxx.xxx) gateway(xxx.xxx.xxx.xxx) dns-servers(xxx.xxx.xxx.xxx)
#
#case wifi
#ifsetup w(fixed) argorithm(wpa/wpa2 etc... now wpa2 olny) SID password [s|d] ip mask gateway dns-servers
#
###########################
wpa_conf=/etc/wpa_supplicant/wpa_supplicant.conf
ifconf=/etc/network/interfaces
dnsconf=/etc/resolvconf.conf


#this function require two argument.
#this function delete network config that is contained in _ 
# first_arg and is specified as second_arg.
#In addition to specified configration, this function delete wpa_config too. 
function deleteConfig() {
log ""
log "(info)delete relevant configuration($2) from interfaces, following config."
log "$(cat $ifconf)"
PRE_IFS=$IFS
IFS=$'\n'

mode=0
cat $1 | while read line
do
 if test $(echo "$line" | grep -E "$2|wpa-conf");
 then
  log "."
  if test $(echo "$line" | grep -E "$2.+inet.+static");
  then
   previous=1
  else
   previous=0 
  fi
 else
  if test $(echo "$line" | grep -E "address|netmask|gateway|dns-servers");
  then
   if test $previous = 1;
   then
    log ".."
   else
    echo "$line" >> $tmpfile
   previous=0
   fi
  else
   echo "$line" >> $tmpfile
   previous=0
  fi
 fi

done
log "-----------------------------------"
#log "$(cat $tmp)"
sudo mv -f $tmpfile $1

IFS=$PRE_IFS
log ""
log "(info)config is deleted, like this..."
log "$(cat $ifconf)"
}

function add_if() {
# $1:IFName
# $2:method
# $3:ip
# $4:mask
# $5:gateway
# $6:dns

log ""
log "(op)add_if $1 $2 $3 $4 $5 $6"
if test $2 = "s" 
then
 echo "iface $1 inet static" >> $ifconf
 echo "address $3" >> $ifconf
 echo "netmask $4" >> $ifconf
 echo "gateway $5" >> $ifconf
 echo "dns-servers $6" >> $ifconf
 echo "name_servers=127.0.0.1" > $dnsconf
 echo "name_servers=$6" >> $dnsconf

 log ""
 log "(info)added following config to interfaces"
 log "iface $1 inet static"
 log "address $3" 
 log "netmask $4" 
 log "gateway $5" 
 log "dns-servers $6" 
 echo "name_servers=127.0.0.1(nameserver)"
 echo "name_servers=$6(nameserver)"


else
 echo "iface $1 inet dhcp" >> $ifconf

 log ""
 log "(info)added following config to interfaces"
 log "iface $1 inet dhcp"
 
fi
echo "wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" >> $ifconf

log ""
log "(info)added following config to interfaces"
log "wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf"
}


#this func has two function.
#First function is a function which edit wpa_configuration.
#second finction is a function which delete current wifi setting and  add  setting about starting interface.
function setup_wifi() {
# $1:IFName
# $2:argorithm
# $3:SID
# $4:password
log ""
log "(op)setup_wifi $1 $2 $3"
echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > $tmpfile
echo "update_config=1" >> $tmpfile
wpa_passphrase $3 $4 | sed -e "/}/i\key_mgmt=WPA-PSK\r\nproto=WPA2\r\npairwise=CCMP\r\ngroup=CCMP\r\npriority=2" >> $tmpfile

log ""
log "(info)following config is created as wpa_supplicant.conf"
log "$(cat $tmpfile)"
sudo mv $tmpfile $wpa_conf 
echo "auto $1" >> $ifconf
echo "allow-hotplug $1" >> $ifconf

log ""
log "(info)added following config to interfaces"
log "auto $1" 
log "allow-hotplug $1" 


}



case $1 in
 e)
  #check arguments
  if test $2 != "s" -a $2 != "d"
  then
   log "2nd argument is not in s,d($2)"
   exit  
  fi 
  if test $2 = "s" -a -z "$6"
  then
   log "if use static, 6 argument is required"
   exit 
  fi
  #main process
  #lookup ethernet-if from NetworkInterface(if which start from "e")
  while read line
  do
   ifname=$line
  done< <(ifconfig | sed -e "/^e/ s/ .\+// p" -e "d") 
  deleteConfig $ifconf  $ifname
  add_if $ifname $2 $3 $4 $5 $6
  echo "start reload"
  sudo /etc/init.d/networking reload
  ;;
 w)
  #check arguments
  if test -z "$5"
  then
   log "arguments is required at least 5"
   exit
  fi
  if test "$5" != "d" -a "$5" != "s"
  then
   log "5th argument is not in s,d- $5 -"
   exit
  fi 
  if test $5 = "s" -a -z "$9"
  then
   log "if use static, 9 argument is required($5)"
   exit 
  fi
  #main process
  #lookup wifi-if from NetworkInterface(if which start from "w")
  while read line
  do
   ifname=$line
  done< <(ifconfig | sed -e "/^w/ s/ .\+// p" -e "d") 
  deleteConfig $ifconf  $ifname
  setup_wifi $ifname $2 $3 $4
  add_if $ifname $5 $6 $7 $8 $9
  echo "start reload"
  sudo /etc/init.d/networking reload
  ;;
 *)
 log "unexpected first arg($1), first is in [w,e]"

esac

