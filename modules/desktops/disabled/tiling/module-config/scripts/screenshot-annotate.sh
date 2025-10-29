#!/usr/bin/env bash

# Screenshot + Annotate Workflow
# Takes a screenshot, copies to clipboard, saves to file, and opens in annotator

XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
save_dir="${XDG_PICTURES_DIR}/Screenshots"
temp_file="/tmp/screenshot-$(date +%s).png"
save_file="$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')"
save_path="${save_dir}/${save_file}"

mkdir -p "$save_dir"

# Ensure required binaries
command -v grimblast >/dev/null 2>&1 || { echo "grimblast not found"; exit 1; }
command -v wl-copy >/dev/null 2>&1 || { echo "wl-copy not found"; exit 1; }
command -v annotator >/dev/null 2>&1 || { echo "annotator not found"; exit 1; }
command -v notify-send >/dev/null 2>&1 || { echo "notify-send not found"; exit 1; }

print_error() {
    cat << EOF
Usage: $(basename "$0") [action]
Valid actions:
  (no args) : Interactive area selection (default)
  s  : Snip current screen (area selection)
  sf : Snip current screen (frozen area selection)
  m  : Capture focused monitor
  p  : Capture all screens
EOF
    exit 1
}

take_screenshot() {
    local mode="$1"
    case "$mode" in
        s|"")   grimblast save area "$temp_file" ;;
        sf)     grimblast --freeze save area "$temp_file" ;;
        m)      grimblast save output "$temp_file" ;;
        p)      grimblast save screen "$temp_file" ;;
        *)      print_error ;;
    esac
}

# Take the screenshot
take_screenshot "$1"

# Check if screenshot was successful
if [ ! -f "$temp_file" ]; then
    notify-send -a "Screenshot" -u critical "Screenshot failed" "Could not capture screenshot"
    exit 1
fi

# Copy to clipboard
wl-copy < "$temp_file"

# Copy to permanent location
cp "$temp_file" "$save_path"

# Launch annotator with the screenshot
annotator "$temp_file" &

# Show notification
notify-send -a "Screenshot" -t 3000 -i "$save_path" "Screenshot captured" "Copied to clipboard and opened in annotator\nSaved: $(basename "$save_file")"

# Clean up temp file after a delay (allow annotator to load it first)
(sleep 5 && rm -f "$temp_file") &