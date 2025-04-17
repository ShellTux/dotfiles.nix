#!/bin/sh
set -e

usage() {
  echo "Usage: $0"
  exit 1
}

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

echo 'Hello world!'
