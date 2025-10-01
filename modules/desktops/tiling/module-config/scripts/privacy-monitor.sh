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
            swaync-client -t "🔴 Camera Access" -b "An application is accessing your camera" --urgency critical
            hyprctl notify -1 5000 "rgb(f38ba8)" "🔴 Camera is being accessed"
        fi
    else
        if [[ -f "$CAMERA_FILE" ]]; then
            rm "$CAMERA_FILE"
            swaync-client -t "✅ Camera Access Ended" -b "Camera access has stopped"
            hyprctl notify -1 3000 "rgb(a6e3a1)" "✅ Camera access ended"
        fi
    fi
}

# Function to check microphone usage (via PulseAudio)
check_microphone() {
    if pactl list source-outputs 2>/dev/null | grep -q "Source Output"; then
        if [[ ! -f "$MIC_FILE" ]]; then
            touch "$MIC_FILE"
            swaync-client -t "🎤 Microphone Access" -b "An application is accessing your microphone" --urgency critical
            hyprctl notify -1 5000 "rgb(f9e2af)" "🎤 Microphone is being accessed"
        fi
    else
        if [[ -f "$MIC_FILE" ]]; then
            rm "$MIC_FILE"
            swaync-client -t "✅ Microphone Access Ended" -b "Microphone access has stopped"
            hyprctl notify -1 3000 "rgb(a6e3a1)" "✅ Microphone access ended"
        fi
    fi
}

# Function to check screen sharing (via active screen capture sessions)
check_screenshare() {
    if pgrep -f "grim\|grimblast\|wf-recorder\|obs" >/dev/null 2>&1; then
        if [[ ! -f "$SCREEN_FILE" ]]; then
            touch "$SCREEN_FILE"
            swaync-client -t "📺 Screen Sharing Active" -b "Screen recording/sharing is active" --urgency critical
            hyprctl notify -1 5000 "rgb(cba6f7)" "📺 Screen sharing is active"
        fi
    else
        if [[ -f "$SCREEN_FILE" ]]; then
            rm "$SCREEN_FILE"
            swaync-client -t "✅ Screen Sharing Ended" -b "Screen sharing has stopped"
            hyprctl notify -1 3000 "rgb(a6e3a1)" "✅ Screen sharing ended"
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