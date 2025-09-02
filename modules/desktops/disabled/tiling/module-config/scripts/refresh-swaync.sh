#!/usr/bin/env bash

# Get current power profile
current_profile=$(powerprofilesctl get 2>/dev/null || echo "balanced")

# Create a temporary swaync config update
config_dir="$HOME/.config/swaync"
temp_config="$config_dir/config.json.tmp"

# Restart swaync to pick up any config changes
pkill swaync 2>/dev/null || true
sleep 0.5
swaync &

# Show current profile status
case "$current_profile" in
    "performance")
        notify-send "⚡ Power Profile Updated" "🚀 Performance mode is now active" -t 2000
        ;;
    "balanced")
        notify-send "⚡ Power Profile Updated" "⚖️ Balanced mode is now active" -t 2000
        ;;
    "power-saver")
        notify-send "⚡ Power Profile Updated" "🔋 Power Saver mode is now active" -t 2000
        ;;
esac