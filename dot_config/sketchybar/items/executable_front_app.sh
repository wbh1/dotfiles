#!/usr/bin/env bash
# INFO="${INFO-$(aerospace list-windows --focused --format '%{app-name}')}"
FRONT_APP_SCRIPT='sketchybar --set $NAME label="${INFO-$(aerospace list-windows --focused --format "%{app-name}")}"'

sketchybar --add event window_focus \
    --add event windows_on_spaces \
    --add item front_app left \
    --set front_app script="$FRONT_APP_SCRIPT" \
    icon.drawing=off \
    background.padding_left=10 \
    background.padding_right=10 \
    label.color=$ORANGE \
    label.font="$FONT:Black:12.0" \
    associated_display=active \
    --subscribe front_app front_app_switched
