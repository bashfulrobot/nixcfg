#!/usr/bin/env bash

# Get current power profile
current_profile=$(powerprofilesctl get 2>/dev/null || echo "balanced")

# Set icon and tooltip based on current profile
case "$current_profile" in
    "performance")
        icon="🚀"
        text="Performance"
        class="performance"
        ;;
    "balanced")
        icon="⚖️"
        text="Balanced"
        class="balanced"
        ;;
    "power-saver")
        icon="🔋"
        text="Power Saver"
        class="power-saver"
        ;;
    *)
        icon="⚡"
        text="Unknown"
        class="unknown"
        ;;
esac

# Output JSON for waybar
printf '{"text":"%s","tooltip":"Power Profile: %s (click to cycle, right-click for menu)","class":"%s","icon":"%s"}\n' "$text" "$text" "$class" "$icon"