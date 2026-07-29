#!/bin/bash
# gammastep waybar module — shows night light status and toggles on click

if pgrep -x gammastep >/dev/null 2>&1; then
    period=$(gammastep -p 2>&1 | grep "Period" | awk '{print $3}')
    temp=$(gammastep -p 2>&1 | grep "temperature" | awk '{print $4}')
    case "$period" in
        Daytime)   icon=""; class="off" ;;
        Night)     icon=""; class="on" ;;
        Transition) icon=""; class="transition" ;;
        *)         icon=""; class="off" ;;
    esac
    echo "{\"text\": \"$icon  $temp\", \"class\": \"$class\", \"tooltip\": \"Gammastep: $period ($temp)\"}"
else
    echo "{\"text\": \" off\", \"class\": \"off\", \"tooltip\": \"Gammastep not running\"}"
fi
