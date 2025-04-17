#!/bin/sh
set -e

if [ "$(pgrep --full '^'"$(basename "$0")" | wc --lines)" -gt 2 ]
then
	printf 'Instance of %s already running\n' "$(basename "$0")"
	exit 1
fi

mpc idleloop player | while read -r _
do
	if ! pgrep '^mpd$' >/dev/null
	then
		printf 'No instance of %s running\n' 'mpd'
		exit 1
	fi

	notify-music --quiet
done
