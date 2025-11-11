#!/bin/sh
set -e

usage() {
  echo "Usage: $(basename "$0") [MOUNT...]"
  exit 1
}

[ "$#" -lt 1 ] && usage

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

for mount
do
  wait
  mount "$mount"
  sleep 1 &
done
