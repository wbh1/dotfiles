#!/bin/bash

# Check if external monitor is connected
if hyprctl monitors | grep -q "HDMI-A-1\|DP-3"; then
    # External monitor connected - disable laptop screen
    hyprctl keyword monitor "eDP-1,disable"
else
    # No external monitor - enable laptop screen
    hyprctl keyword monitor "eDP-1,preferred,auto,1"
fi
