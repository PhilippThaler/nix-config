#!/usr/bin/env bash
# Shows clipboard status for waybar

COUNT=$(cliphist list 2>/dev/null | wc -l)
if [ "$COUNT" -gt 0 ]; then
    echo "{\"text\": \" $COUNT\", \"tooltip\": \"$COUNT items\"}"
else
    echo '{"text": " 0", "tooltip": "Empty"}'
fi
