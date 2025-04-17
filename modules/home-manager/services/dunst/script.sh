#!/bin/sh

log_file="$HOME/.local/share/dunst.log"

if [ ! -f "$log_file" ]
then
  mkdir --parents "$(dirname "$log_file")"
  touch "$log_file"
fi

lines="$(wc --lines "$log_file" | cut --fields=1 --delimiter=' ')"

{
  if [ "$lines" -ne 0 ]
  then
    echo
    echo
    echo
  fi

  env | grep DUNST | sort
} >> "$log_file"

case "$DUNST_URGENCY" in
  # NOTE: Pipewire specific
  LOW)      pw-play "$DUNST_SOUND_LOW" ;;
  NORMAL)   pw-play "$DUNST_SOUND_NORMAL" ;;
  CRITICAL) pw-play "$DUNST_SOUND_CRITICAL" ;;
esac
