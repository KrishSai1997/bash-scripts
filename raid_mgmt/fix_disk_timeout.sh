#!/bin/sh

# tells Linux to wait for disk to timeout in case of write failure instead of dropping a disk as not responding
# courtesy of http://strugglers.net/~andy/blog/2015/11/09/linux-software-raid-and-drive-timeouts/

for disk in `find /sys/block -maxdepth 1 -name 'sd*' | xargs -n 1 basename`
do
    smartctl -q errorsonly -l scterc,70,70 /dev/$disk
 
    if test $? -eq 4
    then
        echo "/dev/$disk doesn't suppport scterc, setting timeout to 180s" '/o\'
        echo 180 > /sys/block/$disk/device/timeout
    else
        echo "/dev/$disk supports scterc " '\o/'
    fi
done

