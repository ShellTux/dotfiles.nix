#!/bin/sh
set -e

# Source: https://gitlab.com/dwt1/dotfiles/-/blob/master/.local/bin/stay?ref_type=heads

usage() {
  echo "Usage: $0 commands"
  echo
  echo "Example: $0 ls .."
  exit 1
}

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

# shellcheck disable=SC2153
for terminal in \
  "${TERMINAL:-}" \
  ghostty \
  kitty \
  alacritty \
  rio \
  konsole \
  foot \
  xterm
do
  command -v "$terminal" || continue
  $terminal -e sh -c "$*; echo -e; tput setaf 5 bold; \
    read -p 'Press any key to exit... ' -s -n 1"
  break
done

