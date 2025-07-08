#!/usr/bin/env sh

CENTER_PADDING=300
if [ $BUILTIN_DISPLAY = "1" ]; then
    CENTER_PADDING=0
fi

sketchybar --add item calendar q \
    --set calendar icon= \
    icon.font.family="$NERD_FONT" \
    label.padding_right=$CENTER_PADDING \
    label.font="$FONT:Black:14.0" \
    label.highlight_color=$BLUE \
    label.width=dynamic \
    label.align=left \
    background.padding_left=0 \
    update_freq=60 \
    script="$PLUGIN_DIR/calendar.sh" \
    click_script="$PLUGIN_DIR/zen.sh"
