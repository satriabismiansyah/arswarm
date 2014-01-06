#!/bin/bash


##########################################################################################################################
#
#
#	multidrones.sh: A bash script to configure multiple ar drones 2 on the same unencrypted network
#
#	Author: Gildas Morvan mail:gildas.morvan@univ-artois.fr homepage:http://www.lgi2a.univ-artois.fr/~morvan/
#
#
##########################################################################################################################

#
os=`uname`

#Wifi interface name of the computer running the script
#Mac Os: generally en0 or en1; Linux : generally eth0 or eth1
interface=en1

#Name of the unencrypted network
network=DRONES

mainnetwork=totocaca

#Last 6 digits of the drone  SSIDs
#declare -a ardronesnetworks=(090658 290876)
declare -a ardronesnetworks=(290876)


#IP of the drones: 192.168.1.$ip
ip=3

#Connect to each drone and modify its network configuration
for i in ${ardronesnetworks[@]}
do
   #Connect to the drone's network
   if [ "$os" == 'Linux' ]; then
     #Linux specific code
     iwconfig $interface mode managed essid ardrone2_$i
   elif [ "$os" == 'Darwin' ]; then
     #Mac OS specific code
	 sudo networksetup -setdhcp Wi-Fi
     networksetup -setairportnetwork $interface ardrone2_$i
   fi

	sleep 10
   #Reconfigure the drone's network connections
   echo "killall udhcpd; ifconfig ath0 down; iwconfig ath0 mode managed essid $network; ifconfig ath0 192.168.1.$ip netmask 255.255.255.0 up; route add default gw 192.168.1.1; exit" > wifi.sh
 expect -f multidrones.expect

   ip=$((ip+1))
done


sleep 10
#Connect to the computer running the script to $network

if [ "$os" == 'Linux' ]; then
   #Linux specific code
   ifconfig $interface down
   iwconfig $interface mode managed essid $network
   sudo ifconfig $interface 192.168.1.2 netmask 255.255.255.0 up
elif [ "$os" == 'Darwin' ]; then
   #Mac OS specific code
          networksetup -setairportnetwork $interface $network
          sudo networksetup -setmanual Wi-Fi 192.168.1.2 255.255.255.0 192.168.1.1
fi

#sudo networksetup -setmanual Ethernet 192.168.1.2 255.255.255.0 192.168.1.1


#Execute missions
#node multidrones.js

#Back the computer running the script to a normal network configuration

#if [ "$os" == 'Linux' ]; then
   #Linux specific code
#   ifconfig $interface down
#iwconfig $interface mode managed essid $mainnetwork
#   sudo ifconfig $interface netmask 255.255.255.0 up
#elif [ "$os" == 'Darwin' ]; then
   #Mac OS specific code
#	sudo networksetup -setdhcp Wi-Fi
#	networksetup -setairportnetwork $interface $mainnetwork
#fi
