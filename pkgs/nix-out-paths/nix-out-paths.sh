#!/bin/sh
set -e

usage() {
	echo "$(basename "$0") [packages]..."
	echo
	echo "Example:"
	echo "$(basename "$0") nixpkgs#wl-clipboard"
	echo "$(basename "$0") -p nixpkgs#mpv nixpkgs#vlc"
	exit 1
}

[ "$#" -lt 1 ] && usage

print_only_paths=false
uris=

for arg
do
	[ "$arg" = -h ] && usage
	[ "$arg" = --help ] && usage
	[ "$arg" = -p ] && print_only_paths=true && continue
	[ "$arg" = --print-only-paths ] && print_only_paths=true && continue
	uris="$uris $arg"
done

for uri in $uris
do
	for d in $(nix build "$uri" --print-out-paths --no-link)
	do
		if $print_only_paths
		then
			echo "$d"
		else
			eza \
				--color=auto \
				--color-scale all \
				--icons \
				--tree \
				--follow-symlinks \
				--git-ignore \
				"$d"
		fi
	done
done
