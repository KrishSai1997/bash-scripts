 #!/bin/bash
 
 # saves state information about storage devices including MD devices
 
 file="/root/raid-status-logs/raid-status.`date +%Y.%m.%d-%H.%M.%S`.log"
 touch $file
 mdadm --examine /dev/sd* >> $file
 lsblk --nodeps >> $file
 cat /proc/mdstat >> $file
 printf "Raid Status Logged to %s\n" $file
 
 
