#!/bin/sh
set -e

fifo="$(mktemp --dry-run)"

mkdir --parents "$(dirname "$fifo")"

mkfifo "$fifo"

diff-so-fancy | tee "$fifo" | {
    if grep --quiet --extended-regex '(Date|added|deleted|modified):' < "$fifo"
    then
        less \
            --tabs=4 \
            --RAW-CONTROL-CHARS \
            --quit-if-one-screen \
            --no-init \
            --chop-long-lines \
            --pattern='^(Date|added|deleted|modified):'
    else
        less \
            --tabs=4 \
            --RAW-CONTROL-CHARS \
            --quit-if-one-screen \
            --no-init \
            --chop-long-lines
    fi
}

rm --force "$fifo"
