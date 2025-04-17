#!/bin/sh
set -e

usage() {
	echo "$(basename "$0") [packages]..."
	echo
	echo "Example:"
	echo "$(basename "$0") nixpkgs#wl-clipboard"
	exit 1
}

[ "$#" -lt 1 ] && usage

for arg
do
	uri="$arg"
	for d in $(nix build "$uri" --print-out-paths --no-link)
	do
		eza \
			--color=auto \
			--color-scale all \
			--icons \
			--tree \
			--follow-symlinks \
			--git-ignore \
			"$d"
		done
done
