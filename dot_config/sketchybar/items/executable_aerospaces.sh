#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change


for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change system_woke \
        --set space.$sid \
        background.color=0x22ffffff \
        background.corner_radius=5 \
        background.height=20 \
        background.drawing=off \
        click_script="aerospace workspace $sid" \
        script="$PLUGIN_DIR/aerospace.sh $sid" \
        updates=when_shown \
        icon=$sid                        \
        icon.padding_left=22                          \
        icon.padding_right=22                         \
        label.padding_right=33                        \
        icon.highlight_color=$RED                     \
        background.padding_left=-8                    \
        background.padding_right=-8                   \
        background.color=$BACKGROUND_1                \
        background.drawing=$DRAW_BG                   \
        label.font="sketchybar-app-font:Regular:16.0" \
        label.background.height=26                    \
        label.background.drawing=on                   \
        label.background.color=$BACKGROUND_2  \
        label.background.corner_radius=9              \
        label.drawing=off

        # background.color=$BACKGROUND_1 \
        # label="$sid" \
        # label.font="sketchybar-app-font:Regular:16.0" \
done


