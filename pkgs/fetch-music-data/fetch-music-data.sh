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

pctl="playerctl --ignore-player=brave"

player_name="$($pctl metadata --format='{{playerName}}')"

case "$player_name" in
  mpd)
    $pctl metadata --format='{{artist}} - {{title}}'
    $pctl metadata --format='Album: {{album}}'
    # $pctl metadata --format='Artist: {{artist}}'
    mpc status | sed --quiet 2p | sed 's/playing/  /;s/paused/  /'
    echo
    $pctl metadata --format='[ {{uc(playerName)}} ]'
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
    $pctl metadata --format='{{artist}} - {{title}}'
    $pctl metadata --format='Album: {{album}}'
    $pctl metadata --format='[ {{status}} ] {{duration(position)}}/{{duration(mpris:length)}}' | sed 's/Playing//;s/Paused//'
    $pctl metadata --format='volume: {{volume * 100}}%'
    ;;
esac
