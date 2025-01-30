#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
# DEBUGVARS="FOCUSED_WORKSPACE=\"$FOCUSED_WORKSPACE\" AEROSPACE_FOCUSED_WORKSPACE=\"$AEROSPACE_FOCUSED_WORKSPACE\" ARG=\"$1\" NAME=\"$NAME\" "
#
# echo "[$(date +'%FT%T')] $DEBUGVARS" >> /tmp/sketchybar.log

if [ "$1" = "${FOCUSED_WORKSPACE-1}" ]; then
    sketchybar --set $NAME background.drawing=on
else
    sketchybar --set $NAME background.drawing=off
fi
