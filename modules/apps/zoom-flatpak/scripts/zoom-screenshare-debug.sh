#!/usr/bin/env bash

# Zoom Screenshare Debug Monitor
# Captures relevant logs to diagnose screenshare failures

LOG_FILE="/tmp/zoom-screenshare-debug-$(date +%Y%m%d-%H%M%S).log"

echo "=== Zoom Screenshare Debug Monitor ===" | tee "$LOG_FILE"
echo "Started at: $(date)" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Monitoring:" | tee -a "$LOG_FILE"
echo "  - PipeWire and WirePlumber" | tee -a "$LOG_FILE"
echo "  - XDG Desktop Portal (Hyprland)" | tee -a "$LOG_FILE"
echo "  - Zoom processes and state" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Instructions:" | tee -a "$LOG_FILE"
echo "  1. Start screenshare (should work)" | tee -a "$LOG_FILE"
echo "  2. Stop screenshare" | tee -a "$LOG_FILE"
echo "  3. Start screenshare again (black screen bug)" | tee -a "$LOG_FILE"
echo "  4. Press Ctrl+C to stop monitoring" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Function to log with timestamps
log_event() {
    echo "[$(date +%H:%M:%S.%3N)] $*" | tee -a "$LOG_FILE"
}

# Monitor system state
monitor_state() {
    while true; do
        log_event "=== State Check ==="

        # PipeWire nodes
        log_event "--- PipeWire Nodes ---"
        pw-cli list-objects | grep -A10 "zoom\|screencopy\|screencast" | tee -a "$LOG_FILE" || log_event "No Zoom/screen nodes"

        # Portal processes
        log_event "--- Portal Processes ---"
        pgrep -af "xdg-desktop-portal" | tee -a "$LOG_FILE"

        sleep 5
    done
}

# Start background state monitoring
monitor_state &
MONITOR_PID=$!

# Monitor journalctl logs
log_event "--- Starting journal monitor ---"
journalctl -f --user -u pipewire -u wireplumber -u xdg-desktop-portal-hyprland -o cat 2>&1 | while read -r line; do
    if echo "$line" | grep -qi "zoom\|screen\|buffer\|error\|fail\|portal"; then
        log_event "JOURNAL: $line"
    fi
done &
JOURNAL_PID=$!

# Cleanup on exit
cleanup() {
    log_event "--- Stopping monitor ---"
    kill $MONITOR_PID $JOURNAL_PID 2>/dev/null || true
    log_event "Log saved to: $LOG_FILE"
    echo ""
    echo "To view the log: cat $LOG_FILE"
    echo "To search for errors: grep -i error $LOG_FILE"
}

trap cleanup EXIT INT TERM

# Wait for user to stop
wait
