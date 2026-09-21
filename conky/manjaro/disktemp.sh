#!/bin/sh
# Print the temperature (°C) of a SATA disk via the drivetemp hwmon driver.
# $1: disk id as in /dev/disk/by-id (stable across boots, unlike sdX names)
# Requires the drivetemp module (/etc/modules-load.d/drivetemp.conf).

dev=$(basename "$(readlink -f "/dev/disk/by-id/$1")")
for t in /sys/block/"$dev"/device/hwmon/hwmon*/temp1_input; do
    [ -r "$t" ] && echo $(( $(cat "$t") / 1000 )) && exit 0
done
echo N/A
