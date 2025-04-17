#!/bin/sh

usage() {
  echo "Usage: $0"
  exit 1
}

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

player_name="$(playerctl metadata --format='{{playerName}}')"

case "$player_name" in
  mpd)
    playerctl metadata --format='{{artist}} - {{title}}'
    playerctl metadata --format='Album: {{album}}'
    # playerctl metadata --format='Artist: {{artist}}'
    mpc status | sed --quiet 2p | sed 's/playing/  /;s/paused/  /'
    echo
    playerctl metadata --format='[ {{uc(playerName)}} ]'
    mpc status \
        | sed -n '3p' \
        | sed 's|\s\{2,\}|;|g;s|: |;|g' \
        |  awk -F';' '
      {
        for (i=1; i<=NF; i+=2) {
          key = $i ":"
          val = $(i+1)
          printf "%-8s %s\n", key, val
        }
    }' \
      | sed 's|off$| |;s|on$| |'
    echo
    mpc stats
    ;;
  *)
    playerctl metadata --format='{{artist}} - {{title}}'
    playerctl metadata --format='Album: {{album}}'
    playerctl metadata --format='[ {{status}} ] {{duration(position)}}/{{duration(mpris:length)}}' | sed 's/Playing//;s/Paused//'
    playerctl metadata --format='volume: {{volume * 100}}%'
    ;;
esac
