#!/usr/bin/env bash

# Screenshot Fullscreen - clipboard first, optional save
# Triggered by: Ctrl+Shift+Super+P

XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
save_dir="${XDG_PICTURES_DIR}/Screenshots"
temp_file="/tmp/screenshot-$(date +%s).png"
save_file="$(date +'%y%m%d_%Hh%Mm%Ss_fullscreen.png')"
save_path="${save_dir}/${save_file}"

mkdir -p "$save_dir"

# Ensure required binaries
command -v grimblast >/dev/null 2>&1 || { echo "grimblast not found"; exit 1; }
command -v wl-copy >/dev/null 2>&1 || { echo "wl-copy not found"; exit 1; }
command -v notify-send >/dev/null 2>&1 || { echo "notify-send not found"; exit 1; }

# Take fullscreen screenshot
grimblast save screen "$temp_file"

# Check if screenshot was successful
if [ ! -f "$temp_file" ]; then
    notify-send -a "Screenshot" -u critical "Screenshot failed" "Could not capture screen"
    exit 1
fi

# Copy to clipboard first (primary action)
wl-copy < "$temp_file"

# Also save to Pictures/Screenshots
cp "$temp_file" "$save_path"

# Show notification
notify-send -a "Screenshot" -t 5000 -i "$save_path" \
    "Fullscreen Screenshot" \
    "📋 Copied to clipboard\n💾 Saved: $(basename "$save_file")"

# Clean up temp file after a delay
(sleep 5 && rm -f "$temp_file") &