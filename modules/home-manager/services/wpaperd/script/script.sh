#!/bin/sh

monitor=$1
wallpaper=$2

[ -z "$monitor" ] && exit 1

notify-send "Wallpaper update: $monitor" \
    --icon="$wallpaper"
