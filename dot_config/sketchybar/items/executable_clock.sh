#!/usr/bin/env sh

sketchybar --add item clock e \
    --set clock icon= \
    icon.font.family="$NERD_FONT" \
    icon.padding_left=200 \
    label.font="$FONT:Black:14.0" \
    label.highlight_color=$BLUE \
    label.width=dynamic \
    label.align=right \
    background.padding_left=0 \
    update_freq=1 \
    script="$PLUGIN_DIR/clock.sh" \
    click_script="$PLUGIN_DIR/zen.sh"
