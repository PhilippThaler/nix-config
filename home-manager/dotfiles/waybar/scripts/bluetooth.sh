#!/bin/bash
# Shows bluetooth status for waybar

if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo '{"text": " off", "class": "disabled"}'
else
    DEVICES=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
    if [ "$DEVICES" -gt 0 ]; then
        echo "{\"text\": \" $DEVICES\", \"class\": \"connected\"}"
    else
        echo '{"text": " on", "class": "enabled"}'
    fi
fi
