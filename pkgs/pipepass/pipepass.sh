#!/bin/sh
set -e

base="$(basename "$(readlink -f "$0")")"

usage() {
  echo "Usage: $0"
  echo "This program doesn't echo password when typing a password"
  echo "Only writes to stdout when fd 1 is not an open terminal"
  echo "$base | cat # Writes to the pipe (stdout)"
  echo "$base       # Doesn't write anything"
  exit 1
}

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

printf 'Password: ' >&2

oldstty=$(stty -g) || exit 1
trap 'stty "$oldstty"' EXIT HUP INT TERM

stty -echo

IFS= read -r password
stty "$oldstty"
trap - EXIT HUP INT TERM

# restore the newline the user expects after pressing Enter
printf '\n' >&2

test -t 1 || printf '%s\n' "$password"

unset password
