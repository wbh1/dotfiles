#!/usr/bin/env sh

CENTER_PADDING=300
if [ $BUILTIN_DISPLAY = "1" ]; then
    CENTER_PADDING=0
fi

sketchybar --add item clock e \
    --set clock icon= \
    icon.font.family="$NERD_FONT" \
    icon.padding_left=$CENTER_PADDING \
    label.font="$FONT:Black:14.0" \
    label.highlight_color=$BLUE \
    label.width=dynamic \
    label.align=right \
    background.padding_left=0 \
    update_freq=10 \
    script="$PLUGIN_DIR/clock.sh" \
    click_script="$PLUGIN_DIR/zen.sh"
