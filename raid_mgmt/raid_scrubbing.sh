#!/bin/bash

# Rotate through the MD devices and initiate a scrub (read-only) test, executes MD devices in random order
# starting the next MD device every 2 days
# then sleep for 30 days and start again

# see https://raid.wiki.kernel.org/index.php/Scrubbing_the_drives

# when registered with /etc/rc.local this will re-initiate at boot

while [ : ]
do

  for disk in `find /sys/block -maxdepth 1 -name 'md*' | xargs -n 1 basename | shuf`
  do
    echo check > /sys/block/$disk/md/sync_action
    cat /proc/mdstat
    echo Running read test of $disk. Have a nice day.
    sleep 2d
   done
   
   sleep 30d
  done
  
