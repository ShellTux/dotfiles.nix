#!/bin/sh
set -e

GIT_TLD="$(git rev-parse --show-toplevel)"

relpath() {
    realpath --relative-to="$GIT_TLD" "$1"
}

if [ "$#" -eq 0 ]
then
    relpath "$(pwd)"
else
    for uri
    do
        relpath "$uri"
    done
fi | sed --regexp-extended 's|^\.?|/|'
