#!/bin/sh
set -e

usage() {
  echo "Usage: $0 <file1> <file2>"
  exit 1
}

[ $# -ne 2 ] && usage

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

file1="$1"
file2="$2"
swapfile="$(sha256sum "$file1" | cut --delimiter=' ' --fields=1)"

if [ -f "$swapfile" ]
then
  echo "Swap file exists: $swapfile"
  exit 1
fi

(
  set -x

  mv "$file1" "$swapfile"
  mv "$file2" "$file1"
  mv "$swapfile" "$file2"
)
