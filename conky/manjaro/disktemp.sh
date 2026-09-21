#!/bin/sh
# Print one conky line per disk exposing a temperature sensor: "<model>:  <temp>°C".
# Meant for ${execpi ...}, so the output is parsed as conky text.
# $1: font for the model label (e.g. 'SFMono Nerd Font Mono:size=10:style=bold')
# SATA disks require the drivetemp module (/etc/modules-load.d/drivetemp.conf);
# NVMe disks expose their sensor natively. USB bridges usually expose none.

font=$1
sep=''
for dev in /sys/block/*; do
    for t in "$dev"/device/hwmon/hwmon*/temp1_input "$dev"/device/hwmon*/temp1_input; do
        [ -r "$t" ] || continue
        # sysfs truncates SATA models to 16 chars: prefer the full name from udev
        model=$(lsblk -dno MODEL "/dev/${dev##*/}" 2>/dev/null)
        [ -n "$model" ] || model=$(cat "$dev/device/model")
        model=$(echo "$model" | sed 's/[[:space:]]*$//')
        printf '%s${alignr}${font %s}%s:  ${font}%d°C' "$sep" "$font" "$model" $(( $(cat "$t") / 1000 ))
        sep='
'
        break
    done
done
