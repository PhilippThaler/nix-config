#!/usr/bin/env bash
# waybar on-click: run nixupdate in a new tab of the scratchpad kitty, never a new window.
set -uo pipefail

TITLE=scratchpad_dropdown
SOCK="${XDG_RUNTIME_DIR:-/tmp}/kitty-scratchpad"
GEOM="resize set 1200 1000, move position center"
CRIT="[title=\"$TITLE\"]"

sock_alive() { [ -S "$SOCK" ] && kitten @ --to "unix:$SOCK" ls >/dev/null 2>&1; }

# "<visible> <pid>" for the scratchpad window, "none" when it does not exist
state() {
    swaymsg -t get_tree 2>/dev/null | jq -r --arg t "$TITLE" '
        [.. | objects | select(.name? == $t)] as $m
        | if ($m | length) == 0 then "none" else "\($m[0].visible) \($m[0].pid)" end'
}

# true when the scratchpad shell has a foreground job we must not interrupt
# (ps, not pgrep: a false "idle" reading here would kill a running job)
scratchpad_busy() {
    local kid comm
    while read -r kid comm; do
        [ "$comm" = kitten ] && continue
        [ -n "$(ps --ppid "$kid" -o pid= 2>/dev/null)" ] && return 0
    done < <(ps --ppid "$1" -o pid=,comm= 2>/dev/null)
    return 1
}

start_scratchpad() {
    setsid kitty --title "$TITLE" -o allow_remote_control=socket-only \
        --listen-on="unix:$SOCK" >/dev/null 2>&1 &
    for _ in {1..50}; do sock_alive && return 0; sleep 0.1; done
    return 1
}

read -r visible_before pid_before <<<"$(state)"

if ! sock_alive; then
    # a scratchpad started before it gained a control socket cannot take tabs
    if [ -n "${pid_before:-}" ]; then
        if scratchpad_busy "$pid_before"; then
            notify-send -a nixupd nixupdate "Scratchpad has a job running - restart it to get tabs"
            exit 1
        fi
        swaymsg "[title=\"$TITLE\"] kill" >/dev/null
        sleep 0.5
    fi
    rm -f "$SOCK"
    if ! start_scratchpad; then
        notify-send -a nixupd nixupdate "Could not start the scratchpad terminal"
        exit 1
    fi
fi

if ! kitten @ --to "unix:$SOCK" launch --type=tab --tab-title=nixupdate \
    zsh -ic 'nixupdate; exec zsh' >/dev/null; then
    notify-send -a nixupd nixupdate "Could not open a scratchpad tab"
    exit 1
fi

# reveal it, unless it was already on screen (`scratchpad show` is a toggle)
if [ "$visible_before" != true ]; then
    sleep 0.1
    swaymsg "$CRIT scratchpad show, $GEOM" >/dev/null
fi
