#!/bin/bash
# Shows pending notification count from swaync
count=$(swaync-client -c 2>/dev/null)
dnd=$(swaync-client -D 2>/dev/null)

if echo "$dnd" | grep -q "true"; then
    echo '{"text": "", "tooltip": "Do Not Disturb", "class": "dnd"}'
elif [ -n "$count" ] && [ "$count" -gt 0 ] 2>/dev/null; then
    echo "{\"text\": \" $count\", \"tooltip\": \"$count notifications\", \"class\": \"active\"}"
else
    echo '{"text": "", "tooltip": "No notifications", "class": "clear"}'
fi
