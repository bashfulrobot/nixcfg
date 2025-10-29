#!/usr/bin/env bash

# Screenshot Annotation - annotate the latest screenshot in ~/Pictures/Screenshots
# Based on your original sys/scripts/screenshot-annotate.sh

XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
save_dir="${XDG_PICTURES_DIR}/Screenshots"

mkdir -p "$save_dir"

# Ensure required binaries
command -v satty >/dev/null 2>&1 || { echo "satty not found"; exit 1; }
command -v notify-send >/dev/null 2>&1 || { echo "notify-send not found"; exit 1; }

# Get the most recent screenshot (like your original sys script)
recent_screenshot=$(ls -t "$save_dir"/*.png 2>/dev/null | head -n1)

# Check if a file was found
if [[ -z "$recent_screenshot" ]]; then
    notify-send -a "Screenshot Annotation" -u critical "No screenshots found" "No screenshot files found in $save_dir"
    exit 1
fi

# Launch satty with arrow tool using CLI flags only (bypass config file)
# Generate output filename for annotated version
annotated_file="$save_dir/annotated-$(date +%Y-%m-%d-%H-%M-%S).png"

# Create empty config to bypass the problematic system one
empty_config="/tmp/satty-empty.toml"
echo "[general]" > "$empty_config"

satty --config "$empty_config" --filename "$recent_screenshot" --initial-tool arrow --output-filename "$annotated_file" --copy-command "wl-copy"

# Clean up old files (like your original script)
find "$save_dir" -type f -mtime +7 -exec rm {} \;