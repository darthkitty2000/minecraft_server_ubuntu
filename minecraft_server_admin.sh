#!/bin/bash

#When running script please enter which server e.g., [M_and_T] as the first argument and which action e.g., [restart] you would like to preform as the second.

#Make sure that network drives are mounted
mount -a

cd /home/tristen/

#Determine which server affect
if [[ $1 == "M_and_T" ]] || [[ $1 == "JJ" ]] || [[ $1 == "modded_minecraft" ]]; then

	server="$1""_minecraft_server"
	cd /home/tristen/"$server"

else

	echo "Server doesn't exist and/or was entered incorrectly"
	exit 0
fi

#Start screen session and minecraft server
turn_on() {

	screen -S "$server" -d -m ./start.sh
	sleep 10
}

#Shutdown Minecraft server and screen socket
turn_off() {

	screen -S "$server" -p 0 -X stuff "/stop^M"
	sleep 30
}

if [[ $2 == "restart" ]]; then

	#Alert anyone currently on server of restart
	screen -S "$server" -p 0 -X stuff "/say Server reboot in 30 seconds. Will be back on in a couple of minutes.^M"
	sleep 30

	turn_off

	#Create backup file name based on the date command
	Date=$(date)
	change_1="${Date// /_}"
	savefilename="${change_1//:/-}"

	#Get the year and month to create folders if they do not already exist for better organization
	year=$(date "+%Y")
	month=$(date "+%B")

	#The full path for backups to be made to
	netbackupdir="/home/tristen/truenas/"$server"_backups/"$year"/"$month""

	if ! [ -d "$netbackupdir" ]; then #If the full path including the year and month doesn't already exist
		mkdir -p "$netbackupdir"                                                                     #Create the full path
		cp -r /home/tristen/"$server"/world "$netbackupdir"   #Copy the world folder into the backup location
		mv "$netbackupdir"/world "$netbackupdir"/"$savefilename"   #Rename the folder
	else
		cp -r /home/tristen/"$server"/world "$netbackupdir"   #Copy the world folder into the backup location
        	mv "$netbackupdir"/world "$netbackupdir"/"$savefilename"   #Rename the folder
	fi

	turn_on

elif [[ $2 == "turn_off" ]]; then

	#Alert anyone on the server that it will be shutting down
	screen -S "$server" -p 0 -X stuff "/say Server going down for maintenance in 30 seconds. If you have any questions please message me on discord @lil_fleece#4126^M"
	sleep 30

	turn_off

elif [[ $2 == "turn_on" ]]; then

	turn_on

else

	echo "Server action doesn't exist and/or was entered incorrectly."

fi
exit 0
