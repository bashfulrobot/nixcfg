#!/usr/bin/env bash

# Enhanced wf-recorder script for Hyprland
# Features: Toggle recording, notifications, proper cleanup

RECORD_DIR="$HOME/Videos"
PID_FILE="/tmp/wf-recorder.pid"

# Create Videos directory if it doesn't exist
mkdir -p "$RECORD_DIR"

# Check if already recording
if pgrep -x "wf-recorder" > /dev/null; then
    # Stop recording
    pkill -INT -x wf-recorder
    rm -f "$PID_FILE"
    notify-send \
        -h string:x-canonical-private-synchronous:wf-recorder \
        -t 2000 \
        -i media-record \
        "Recording Stopped" \
        "Video saved to $RECORD_DIR"
    exit 0
fi

# Start recording notification
notify-send \
    -h string:x-canonical-private-synchronous:wf-recorder \
    -t 2000 \
    -i media-record \
    "Recording Started" \
    "Press Super+Ctrl+R to stop"

# Generate filename with timestamp
datetime=$(date +%Y-%m-%d_%H-%M-%S)
output_file="$RECORD_DIR/screen-record_$datetime.mp4"

# Record with simple settings
wf-recorder --file "$output_file"