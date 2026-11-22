#!/bin/sh
set -e

notification=true

# Pull notification flags out of the arguments, keeping the rest in order.
for arg in "$@"; do
	case "$arg" in
		-n | --no-notification)
			notification=false
			shift
			;;
		*)
			shift
			set -- "$@" "$arg"
			;;
	esac
done

usage() {
	echo "Usage: $(basename "$0") [-n|--no-notification] [amount] [+/-]"
	echo "The amount is in percentage (do not include %)"
	echo "Options:"
	echo "  -n, --no-notification   Disable desktop notification"
	echo "amount   the amount to increase or decrease brightness (integer between 0 and 100)"
	echo "Example: $(basename "$0") 2"
	echo "Example: $(basename "$0") 5 +"
	echo "Example: $(basename "$0") 5 -"
	echo "Example: $(basename "$0") 5 + --no-notification"
	exit 1
}

get_brightness() {
	brightnessctl | awk '/Current brightness/ {print $4}' | sed 's/[()%]//g'
	return
}

set_brightness() {
	case $2 in
		+) brightnessctl set "+$1%" --quiet ;;
		-) brightnessctl set "$1%-" --min-value 1 --quiet ;;
		"") brightnessctl set "$1%" --min-value 1 --quiet ;;
	esac
}

if [ $# -eq 0 ]
then
	printf 'Brightness: %d%%\n' "$(get_brightness)"
else
	case "$1$2" in
		notify) ;;
		[0-9][+-]) set_brightness "$1" "$2" ;;
		[0-9]) set_brightness "$1" ;;
		*) usage ;;
	esac
fi

if [ "$notification" = true ]
then
	appName="$(basename "$0")"
	msgTag='brightness'
	brightness="$(get_brightness)"
	brightness_level="$(echo "$brightness" | awk '{ print sprintf("%.0f", $1/100*4) }')"
	case "$brightness_level" in
		0) icon='brightness-low' ;;
		1) icon='brightness-medium' ;;
		2) icon='brightness-medium' ;;
		3) icon='brightness-high' ;;
		4) icon='brightness-high' ;;
	esac
	notify-send \
		--app-name="$appName" \
		--urgency=low \
		--icon="$icon" \
		--hint=string:x-dunst-stack-tag:"$msgTag" \
		--hint=int:value:"$brightness" \
		"Brightness: ${brightness}%"
fi
