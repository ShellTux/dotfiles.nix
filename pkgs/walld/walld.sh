#!/bin/sh
set +u

mpv_named_pipe=/tmp/mpv-commands
mpvpaper_pid=

usage() {
	echo "Usage: $0 [options]"
	for arg
	do
		echo "$arg"
	done
	echo
	echo "Wallpaper daemon and controller"
	echo
	echo "When run for the first time without arguments, this script starts the wallpaper changer as a daemon."
	echo "Subsequent calls allow you to execute commands or retrieve properties related to the wallpaper."
	echo
	echo "Options:"
	echo "  -h, --help         Show this help message and exit"
	echo
	echo 'Options available:'
	list_options | sed 's|^|  - |'
	echo
	echo "Commands Available:"
	list_commands | sed 's|^|  - |'
	echo
	echo "Properties Available:"
	list_properties | sed 's|^|  - |'
	echo
	echo 'Examples:'
	echo "$ $0 ~/Wallpapers"
	echo "$ $0 commands"
	echo "$ $0 properties"
	echo "$ $0 commands playlist-next"
	exit 1
}

startup() {
	rm --force "$mpv_named_pipe"
	# shellcheck disable=SC2068
	mpvpaper \
		--mpv-options='loop=yes panscan=1.0 image-display-duration=inf terminal=no shuffle input-ipc-server='"$mpv_named_pipe"'' \
		'*' $@ &
	mpvpaper_pid=$!
}

cleanup() {
	echo 'quit' | socat - "$mpv_named_pipe"
	rm "$mpv_named_pipe"
}

mpvpaper_command() {
	[ "$#" -eq 0 ] && return
	# shellcheck disable=SC2198
	[ -z "$@" ] && return
	echo "$@" | socat - "$mpv_named_pipe"
}

list_options() {
	echo commands
	echo properties
}

list_commands() {
	echo playlist-next
	echo playlist-prev
	echo cycle pause
	echo playlist-shuffle
	echo context-menu
	echo show-progress
	echo quit
}

list_properties() {
	echo path
}

for arg
do
	[ "$arg" = -h ] && usage
	[ "$arg" = --help ] && usage
done

if ! pgrep mpvpaper >/dev/null
then
	if [ "$#" -eq 0 ]
	then
		usage 'No directory provided for the wallpapers'
	else
		# shellcheck disable=SC2068
		startup $@
	fi
else
	[ ! -t 1 ] && exit 0

	if [ -n "$1" ]
	then
		option="$1"
	else
		option="$(list_options | fzf)"
	fi

	case "$option" in
		commands)
			if [ -n "$2" ]
			then
				com="$2"
			else
				com="$(list_commands | fzf)"
			fi

			mpvpaper_command "$com"
			exit 0
			;;
		properties)
			property="$(list_properties | fzf)"
			response="$(echo '{ "command": ["get_property", "'"$property"'"] }' | socat - "$mpv_named_pipe")"

			error="$(echo "$response" | jq --raw-output '.error')"
			data="$(echo "$response" | jq --raw-output '.data')"

			if [ "$error" = success ]
			then
				echo "$data"
				exit 0
			fi

			echo "$response" | jq

			exit 1
			;;
		*)
			usage "Invalid Option: $option"
			;;
	esac

	# shellcheck disable=SC2317
	exit 0
fi

trap cleanup EXIT

while true
do
	sleep 1
	waitpid --timeout=600 "$mpvpaper_pid" && exit 0
	mpvpaper_command playlist-next
done
