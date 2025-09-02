#!/usr/bin/env bash

# Get current power profile
current_profile=$(powerprofilesctl get 2>/dev/null || echo "unknown")

# Set icon and label based on current profile
case "$current_profile" in
    "performance")
        echo "\t🚀   Power Profile (Performance)\t"
        ;;
    "balanced")
        echo "\t⚖️   Power Profile (Balanced)\t"
        ;;
    "power-saver")
        echo "\t🔋   Power Profile (Power Saver)\t"
        ;;
    *)
        echo "\t⚡   Power Profile\t"
        ;;
esac