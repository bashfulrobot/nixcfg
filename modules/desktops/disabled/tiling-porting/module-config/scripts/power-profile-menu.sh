#!/usr/bin/env bash

# Get current power profile
current_profile=$(powerprofilesctl get 2>/dev/null || echo "balanced")

# Create menu options with indicators
performance_option="🚀 Performance"
balanced_option="⚖️ Balanced"
powersaver_option="🔋 Power Saver"

# Add indicator to current profile
case "$current_profile" in
    "performance")
        performance_option="🚀 Performance ✓"
        ;;
    "balanced")
        balanced_option="⚖️ Balanced ✓"
        ;;
    "power-saver")
        powersaver_option="🔋 Power Saver ✓"
        ;;
esac

# Show menu using wofi (wayland dmenu replacement)
selected=$(printf "%s\n%s\n%s" "$performance_option" "$balanced_option" "$powersaver_option" | \
    wofi --dmenu --prompt "Power Profile" --width 250 --height 150 \
    --style ~/.config/wofi/style.css 2>/dev/null || \
    printf "%s\n%s\n%s" "$performance_option" "$balanced_option" "$powersaver_option" | \
    dmenu -p "Power Profile:")

# Process selection
case "$selected" in
    *"Performance"*)
        powerprofilesctl set performance
        notify-send "🚀 Power Profile" "Switched to Performance mode" -t 3000
        ;;
    *"Balanced"*)
        powerprofilesctl set balanced
        notify-send "⚖️ Power Profile" "Switched to Balanced mode" -t 3000
        ;;
    *"Power Saver"*)
        powerprofilesctl set power-saver
        notify-send "🔋 Power Profile" "Switched to Power Saver mode" -t 3000
        ;;
esac