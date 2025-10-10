#!/usr/bin/env bash

# Nautilus script to copy full path of selected file/folder to clipboard

# Use wl-copy for Wayland or xclip for X11
if command -v wl-copy >/dev/null 2>&1; then
    clipboard_cmd="wl-copy"
elif command -v xclip >/dev/null 2>&1; then
    clipboard_cmd="xclip -selection clipboard"
else
    notify-send "Error" "No clipboard utility found (wl-copy or xclip required)" -i error
    exit 1
fi

# Copy all selected paths
paths=()
for file in $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS; do
    if [[ -n "$file" ]]; then
        paths+=("$file")
    fi
done

if [[ ${#paths[@]} -eq 0 ]]; then
    notify-send "Error" "No files selected" -i error
    exit 1
fi

# Join paths with newlines and copy to clipboard
(IFS=$'\n'; echo "${paths[*]}" | $clipboard_cmd)

# Show notification
if [[ ${#paths[@]} -eq 1 ]]; then
    notify-send "Path Copied" "${paths[0]}" -i "edit-copy"
else
    notify-send "Paths Copied" "${#paths[@]} paths copied to clipboard" -i "edit-copy"
fi

exit 0