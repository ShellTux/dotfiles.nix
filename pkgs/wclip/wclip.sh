#!/bin/sh
set -e

usage() {
  echo "Usage: $0"
  echo "This script reads from stdin and copies the text to the clipboard."

  [ "$#" -gt 0 ] && echo
  for arg
  do
    echo "$arg"
  done
  exit 1
}

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

[ "$#" -ne 0 ] && usage && exit 1

cat | case "$XDG_SESSION_TYPE" in
  wayland) wl-copy ;;
  x11) xclip -selection clipboard ;;
  *) usage "Unsupported session type: $XDG_SESSION_TYPE" ;;
esac
