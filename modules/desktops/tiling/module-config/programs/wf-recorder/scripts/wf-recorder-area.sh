#!/usr/bin/env bash

# Area recording script for wf-recorder with slurp selection

RECORD_DIR="$HOME/Videos"
PID_FILE="/tmp/wf-recorder-area.pid"

# Create Videos directory if it doesn't exist
mkdir -p "$RECORD_DIR"

# Check if already recording
if pgrep -f "wf-recorder.*-g" > /dev/null; then
    # Stop area recording
    pkill -f "wf-recorder.*-g"
    rm -f "$PID_FILE"
    notify-send \
        -h string:x-canonical-private-synchronous:wf-recorder \
        -t 2000 \
        -i media-record \
        "Area Recording Stopped" \
        "Video saved to $RECORD_DIR"
    exit 0
fi

# Use slurp to select area
geometry=$(slurp)
if [ $? -ne 0 ] || [ -z "$geometry" ]; then
    notify-send \
        -h string:x-canonical-private-synchronous:wf-recorder \
        -t 2000 \
        -i dialog-error \
        "Recording Cancelled" \
        "No area selected"
    exit 1
fi

# Generate filename with timestamp
datetime=$(date +%Y-%m-%d_%H-%M-%S)
output_file="$RECORD_DIR/area-record_$datetime.mp4"

notify-send \
    -h string:x-canonical-private-synchronous:wf-recorder \
    -t 2000 \
    -i media-record \
    "Area Recording Started" \
    "Press Super+Shift+Ctrl+R to stop"

# Record selected area
wf-recorder \
    --geometry "$geometry" \
    --bframes max_b_frames \
    --codec libx264 \
    --pixel-format yuv420p \
    --audio \
    --file "$output_file" &

# Save PID for cleanup
echo $! > "$PID_FILE"

exit 0