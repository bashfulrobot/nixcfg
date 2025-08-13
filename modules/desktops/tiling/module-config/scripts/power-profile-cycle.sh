#!/usr/bin/env bash

# Get current power profile
current_profile=$(powerprofilesctl get 2>/dev/null || echo "balanced")

# Cycle to next profile
case "$current_profile" in
    "performance")
        next_profile="balanced"
        next_icon="⚖️"
        next_name="Balanced"
        ;;
    "balanced")
        next_profile="power-saver"
        next_icon="🔋"
        next_name="Power Saver"
        ;;
    "power-saver")
        next_profile="performance"
        next_icon="🚀"
        next_name="Performance"
        ;;
    *)
        next_profile="balanced"
        next_icon="⚖️"
        next_name="Balanced"
        ;;
esac

# Set the new profile
powerprofilesctl set "$next_profile"

# Show notification
notify-send "$next_icon Power Profile" "Switched to $next_name mode" -t 3000

# Force waybar to update by sending signal
pkill -RTMIN+8 waybar 2>/dev/null || true