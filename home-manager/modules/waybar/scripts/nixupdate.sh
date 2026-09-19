#!/usr/bin/env bash
# Waybar indicator: shows an icon once ~/nix-config hasn't been updated in 7 days.
set -euo pipefail

THRESHOLD=7
state="${XDG_STATE_HOME:-$HOME/.local/state}/nixupd"

if [[ ! -f $state/last ]]; then
    echo '{"text": "󰚰", "tooltip": "nixupd: no update recorded yet — click to run nixupdate", "class": "stale"}'
    exit 0
fi

last=$(<"$state/last")
age=$(( ($(date +%s) - last) / 86400 ))

if ((age >= THRESHOLD)); then
    printf '{"text": "󰚰", "tooltip": "Last nixupdate: %s (%sd ago)\\nClick to update", "class": "stale"}\n' \
        "$(date -d "@$last" '+%Y-%m-%d')" "$age"
else
    echo '{"text": "", "class": "fresh"}'
fi
