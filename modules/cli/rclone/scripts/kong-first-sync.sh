#!/usr/bin/env bash

# First-time sync setup for Kong folder
# This script initializes the Kong folder sync by creating the initial state

set -euo pipefail

# Configuration
LOCAL_KONG_DIR="${HOME}/Documents/Kong"
REMOTE_KONG="gdrive:"  # Root of Google Drive
LOG_FILE="${HOME}/.local/share/rclone/kong-first-sync.log"

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$LOCAL_KONG_DIR"

# Function to rotate logs if they get too large
rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        local log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
        local max_size=$((10 * 1024 * 1024))  # 10MB

        if [ "$log_size" -gt "$max_size" ]; then
            # Keep last 3 rotated logs
            [ -f "${LOG_FILE}.2" ] && mv "${LOG_FILE}.2" "${LOG_FILE}.3"
            [ -f "${LOG_FILE}.1" ] && mv "${LOG_FILE}.1" "${LOG_FILE}.2"
            mv "$LOG_FILE" "${LOG_FILE}.1"
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log rotated (previous log was ${log_size} bytes)" > "$LOG_FILE"
        fi
    fi
}

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Function to prompt user for sync direction
prompt_sync_direction() {
    echo "Kong folder first-time sync setup"
    echo "==============================="
    echo ""
    echo "Local Kong folder: $LOCAL_KONG_DIR"
    echo "Remote Kong folder: $REMOTE_KONG"
    echo ""

    # Check what exists where
    local local_files=0
    local remote_files=0

    if [ -d "$LOCAL_KONG_DIR" ] && [ "$(ls -A "$LOCAL_KONG_DIR" 2>/dev/null)" ]; then
        local_files=$(find "$LOCAL_KONG_DIR" -type f | wc -l)
        log "Local Kong folder contains $local_files files"
    fi

    if rclone lsf "$REMOTE_KONG" 2>/dev/null | grep -q .; then
        remote_files=$(rclone lsf "$REMOTE_KONG" --files-only | wc -l)
        log "Remote Kong folder contains $remote_files files"
    fi

    echo "Local files: $local_files"
    echo "Remote files: $remote_files"
    echo ""

    if [ "$local_files" -gt 0 ] && [ "$remote_files" -gt 0 ]; then
        echo "WARNING: Both local and remote Kong folders contain files!"
        echo "Choose sync direction carefully to avoid data loss."
        echo ""
    fi

    echo "Choose sync direction:"
    echo "1) Local → Remote (upload local to Google Drive)"
    echo "2) Remote → Local (download from Google Drive to local)"
    echo "3) Cancel setup"
    echo ""

    while true; do
        read -p "Enter choice [1-3]: " choice
        case $choice in
            1)
                return 1
                ;;
            2)
                return 2
                ;;
            3)
                log "User cancelled setup"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# Function to sync local to remote
sync_local_to_remote() {
    log "Starting initial sync: Local → Remote"

    rclone sync "$LOCAL_KONG_DIR" "$REMOTE_KONG" \
        --create-empty-src-dirs \
        --progress \
        --log-file="$LOG_FILE" \
        --log-level=INFO \
        --exclude ".DS_Store" \
        --exclude "Thumbs.db" \
        --exclude ".tmp/" \
        --exclude "*.tmp" \
        --exclude ".git/" \
        --exclude "node_modules/" \
        --exclude ".cache/" \
        --exclude "*.lock"

    log "Initial sync completed: Local → Remote"
    notify-send --app-name="Kong Setup" "Setup Complete" "Kong folder synced to Google Drive" -u normal
}

# Function to sync remote to local
sync_remote_to_local() {
    log "Starting initial sync: Remote → Local"

    rclone sync "$REMOTE_KONG" "$LOCAL_KONG_DIR" \
        --create-empty-src-dirs \
        --progress \
        --log-file="$LOG_FILE" \
        --log-level=INFO \
        --exclude ".DS_Store" \
        --exclude "Thumbs.db" \
        --exclude ".tmp/" \
        --exclude "*.tmp" \
        --exclude ".git/" \
        --exclude "node_modules/" \
        --exclude ".cache/" \
        --exclude "*.lock"

    log "Initial sync completed: Remote → Local"
    notify-send --app-name="Kong Setup" "Setup Complete" "Kong folder synced from Google Drive" -u normal
}

# Main execution
main() {
    # Rotate logs if needed
    rotate_log

    log "Starting Kong folder first-time sync setup"

    # Check if rclone is available
    if ! command -v rclone &> /dev/null; then
        log "ERROR: rclone not found in PATH"
        notify-send --app-name="Kong Setup" "Error" "rclone not found" -u critical
        exit 1
    fi

    # Check if Google Drive is accessible
    if ! rclone lsd gdrive: &> /dev/null; then
        log "ERROR: Cannot access Google Drive. Check rclone configuration."
        notify-send --app-name="Kong Setup" "Connection Error" "Cannot access Google Drive" -u critical
        exit 1
    fi

    # Prompt for sync direction
    prompt_sync_direction
    local direction=$?

    # Perform the sync based on user choice
    case $direction in
        1)
            sync_local_to_remote
            ;;
        2)
            sync_remote_to_local
            ;;
    esac

    log "Kong folder setup completed successfully"
    echo ""
    echo "Setup complete! You can now use:"
    echo "  kong-sync.sh      - For regular bidirectional sync"
    echo "  kong-sync.sh check - To check sync status"
}

main "$@"