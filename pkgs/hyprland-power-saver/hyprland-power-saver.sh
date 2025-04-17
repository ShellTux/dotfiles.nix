#!/bin/sh
set -e

usage() {
  echo "Usage: $0"
  exit 1
}

apply_hyprland_profile() {
  case "$1" in
    discharging)
      hyprctl --batch "\
        keyword decoration:shadow:enabled false;\
        keyword animations:enabled false;\
        keyword misc:vfr true;\
        keyword decoration:blur:enabled false"
      ;;
    charging)
      hyprctl --batch "\
        keyword decoration:shadow:enabled true;\
        keyword animations:enabled true;\
        keyword misc:vfr false;\
        keyword decoration:blur:enabled true"
      ;;
    *) usage ;;
  esac
}

for arg
do
  [ "$arg" = -h ] && usage
  [ "$arg" = --help ] && usage
done

bat_status="$(cat /sys/class/power_supply/A*/online 2>/dev/null | sed 's|0|discharging|;s|1|charging|')"

case "$bat_status" in
  discharging)
    notify-send \
      --urgency=critical \
      'Battery is discharging' \
      'Applying power save profile for Hyprland'
    ;;
  charging)
    notify-send \
      --urgency=normal \
      'Battery is charging' \
      'Restoring from power save profile for Hyprland'
    ;;
  *) usage ;;
esac

apply_hyprland_profile "$bat_status"
