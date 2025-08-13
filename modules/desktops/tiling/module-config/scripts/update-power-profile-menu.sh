#!/usr/bin/env bash

# Get current power profile
current_profile=$(powerprofilesctl get 2>/dev/null || echo "balanced")

# Create labels with green circle for active profile
performance_label="🚀   Performance"
balanced_label="⚖️   Balanced"
powersaver_label="🔋   Power Saver"

case "$current_profile" in
    "performance")
        performance_label="🚀 🟢 Performance (Active)"
        ;;
    "balanced")
        balanced_label="⚖️ 🟢 Balanced (Active)"
        ;;
    "power-saver")
        powersaver_label="🔋 🟢 Power Saver (Active)"
        ;;
esac

# Update swaync with current profile indicators
# This would require swaync to support dynamic menu updates
# For now, just send a notification with current status
notify-send "⚡ Power Profile Status" "Currently active: $current_profile" -t 3000