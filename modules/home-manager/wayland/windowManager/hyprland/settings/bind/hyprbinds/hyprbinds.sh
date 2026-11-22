#!/bin/sh

hyprctl -j binds | jq -r '
def mods: .modmask as $m
| [[64, "Super"], [4, "Ctrl"], [8, "Alt"], [1, "Shift"]]
| map(select(($m / .[0] | floor) % 2 == 1) | .[1]);
    .[]
| select(.has_description)
    | ((mods + [.key]) | join("+")) + "\t" + .description
    ' | noctalia dmenu -p Keybinds >/dev/null
