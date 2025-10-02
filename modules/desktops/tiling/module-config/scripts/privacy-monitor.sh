#!/usr/bin/env bash
# Privacy monitoring script for desktop notifications
# Monitors camera, microphone, and screen sharing access

CACHE_DIR="/tmp/privacy-monitor"
mkdir -p "$CACHE_DIR"

CAMERA_FILE="$CACHE_DIR/camera"
MIC_FILE="$CACHE_DIR/mic"
SCREEN_FILE="$CACHE_DIR/screen"

# Function to check camera usage
check_camera() {
    if lsof /dev/video* 2>/dev/null | grep -v COMMAND | head -1 >/dev/null; then
        if [[ ! -f "$CAMERA_FILE" ]]; then
            touch "$CAMERA_FILE"
            notify-send "🔴 Camera Access" "An application is accessing your camera" -u critical
        fi
    else
        if [[ -f "$CAMERA_FILE" ]]; then
            rm "$CAMERA_FILE"
            notify-send "✅ Camera Access Ended" "Camera access has stopped" -u normal
        fi
    fi
}

# Function to check microphone usage (via PulseAudio)
check_microphone() {
    if pactl list source-outputs 2>/dev/null | grep -q "Source Output"; then
        if [[ ! -f "$MIC_FILE" ]]; then
            touch "$MIC_FILE"
            notify-send "🎤 Microphone Access" "An application is accessing your microphone" -u critical
        fi
    else
        if [[ -f "$MIC_FILE" ]]; then
            rm "$MIC_FILE"
            notify-send "✅ Microphone Access Ended" "Microphone access has stopped" -u normal
        fi
    fi
}

# Function to check screen sharing (via active screen capture sessions)
check_screenshare() {
    if pgrep -f "grim\|grimblast\|wf-recorder\|obs" >/dev/null 2>&1; then
        if [[ ! -f "$SCREEN_FILE" ]]; then
            touch "$SCREEN_FILE"
            notify-send "📺 Screen Sharing Active" "Screen recording/sharing is active" -u critical
        fi
    else
        if [[ -f "$SCREEN_FILE" ]]; then
            rm "$SCREEN_FILE"
            notify-send "✅ Screen Sharing Ended" "Screen sharing has stopped" -u normal
        fi
    fi
}

# Main monitoring loop
while true; do
    check_camera
    check_microphone
    check_screenshare
    sleep 2
done