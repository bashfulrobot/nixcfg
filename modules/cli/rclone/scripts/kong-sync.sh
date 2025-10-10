#!/usr/bin/env bash

# Bidirectional sync script for Kong folder with Google Drive
# Usage: kong-sync.sh [dry-run|check]

set -euo pipefail

# Configuration
LOCAL_KONG_DIR="${HOME}/Documents/Kong"
REMOTE_KONG="gdrive:"  # Root of Google Drive
LOG_FILE="${HOME}/.local/share/rclone/kong-sync.log"
LOCK_FILE="/tmp/kong-sync.lock"

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

# Function to check for lock file (prevent multiple syncs)
check_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log "Another sync process is running (PID: $pid), exiting"
            exit 1
        else
            log "Removing stale lock file"
            rm -f "$LOCK_FILE"
        fi
    fi
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT
}

# Function to detect potential conflicts
detect_conflicts() {
    log "Checking for potential conflicts..."

    # Create temporary files for analysis
    local local_files="/tmp/kong-sync-local.txt"
    local remote_files="/tmp/kong-sync-remote.txt"
    local conflicts_found=false

    # Get file lists with timestamps
    find "$LOCAL_KONG_DIR" -type f -exec stat -c "%Y %n" {} \; 2>/dev/null > "$local_files" || true
    rclone lsl "$REMOTE_KONG" 2>/dev/null | awk '{print $2 " " $4}' > "$remote_files" || true

    # Check for files that exist in both places and may have conflicts
    while IFS= read -r line; do
        local file_path=$(echo "$line" | awk '{print $2}' | sed "s|^$LOCAL_KONG_DIR/||")
        local local_time=$(echo "$line" | awk '{print $1}')

        if grep -q "$file_path" "$remote_files"; then
            local remote_time=$(grep "$file_path" "$remote_files" | head -1 | awk '{print $1}')
            local time_diff=$((local_time - remote_time))

            # If times differ by more than 60 seconds, potential conflict
            if [ ${time_diff#-} -gt 60 ]; then
                log "⚠ Potential conflict detected: $file_path (local: $(date -d @$local_time), remote: $(date -d @$remote_time))"
                conflicts_found=true
            fi
        fi
    done < "$local_files"

    # Cleanup
    rm -f "$local_files" "$remote_files"

    if [ "$conflicts_found" = true ]; then
        log "⚠ WARNING: Potential conflicts detected! Consider manual review before sync."
        if [[ "${1:-}" != "dry-run" ]]; then
            # Ask user to confirm (only in interactive mode)
            if [ -t 0 ]; then
                echo "Potential conflicts detected. Continue with sync? [y/N]"
                read -r response
                if [[ ! "$response" =~ ^[Yy] ]]; then
                    log "User cancelled sync due to conflicts"
                    return 1
                fi
            else
                log "Running in non-interactive mode, proceeding with sync"
            fi
        fi
    else
        log "✓ No conflicts detected"
    fi

    return 0
}

# Function to validate remote access and security
validate_remote_access() {
    log "Validating Google Drive access and security..."

    # Check basic connectivity
    if ! rclone lsd gdrive: &> /dev/null; then
        log "✗ ERROR: Cannot access Google Drive. Check rclone configuration."
        notify-send --app-name="Kong Sync" "Connection Error" "Cannot access Google Drive" -u critical
        return 1
    fi

    # Get account info to verify we're connected to the right account
    local account_info=$(rclone about gdrive: --json 2>/dev/null || echo "{}")
    local used_space=$(echo "$account_info" | jq -r '.used // "unknown"' 2>/dev/null || echo "unknown")
    local total_space=$(echo "$account_info" | jq -r '.total // "unknown"' 2>/dev/null || echo "unknown")

    log "✓ Connected to Google Drive (Used: $used_space, Total: $total_space)"

    # Check if we can write to the drive (test with a small file)
    local test_file="/tmp/kong-sync-test-$$"
    echo "test" > "$test_file"

    if rclone copy "$test_file" gdrive:/ &> /dev/null; then
        log "✓ Write access confirmed"
        # Clean up test file
        rclone delete gdrive:/kong-sync-test-$$ &> /dev/null || true
        rm -f "$test_file"
    else
        log "✗ ERROR: Cannot write to Google Drive. Check permissions."
        notify-send --app-name="Kong Sync" "Permission Error" "Cannot write to Google Drive" -u critical
        rm -f "$test_file"
        return 1
    fi

    # Warn if this looks like a different account than expected
    local drive_usage_gb=$(echo "$used_space" | sed 's/[^0-9]//g' | head -c 10)
    if [ -n "$drive_usage_gb" ] && [ "$drive_usage_gb" -lt 100000000 ]; then  # Less than ~100MB
        log "⚠ WARNING: Drive appears to have very little usage. Verify this is the correct Google account."
    fi

    log "✓ Remote access validation completed"
    return 0
}

# Function to sync bidirectionally with retry logic
sync_bidirectional() {
    local dry_run=""
    if [[ "${1:-}" == "dry-run" ]]; then
        dry_run="--dry-run"
        log "Performing dry run of bidirectional sync"
    else
        log "Starting bidirectional sync"
    fi

    # Check for conflicts before proceeding
    if ! detect_conflicts "$1"; then
        log "✗ Sync aborted due to conflicts or user cancellation"
        return 1
    fi

    # Function to perform sync with retry
    sync_with_retry() {
        local source="$1"
        local dest="$2"
        local direction="$3"
        local max_retries=3
        local retry_count=0

        while [ $retry_count -lt $max_retries ]; do
            log "Syncing $direction (attempt $((retry_count + 1))/$max_retries)..."

            if rclone sync "$source" "$dest" \
                --create-empty-src-dirs \
                --fast-list \
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
                --exclude "*.lock" \
                --retries 2 \
                --low-level-retries 3 \
                $dry_run; then
                log "✓ $direction sync completed successfully"
                return 0
            else
                local exit_code=$?
                retry_count=$((retry_count + 1))

                if [ $retry_count -lt $max_retries ]; then
                    log "⚠ $direction sync failed (exit code: $exit_code), retrying in 30 seconds..."
                    sleep 30
                else
                    log "✗ $direction sync failed after $max_retries attempts (exit code: $exit_code)"
                    notify-send --app-name="Kong Sync" "Sync Failed" "$direction sync failed after $max_retries attempts" -u critical
                    return $exit_code
                fi
            fi
        done
    }

    # Sync local to remote first (push changes)
    if ! sync_with_retry "$LOCAL_KONG_DIR" "$REMOTE_KONG" "local → remote"; then
        log "✗ Failed to sync local to remote, aborting bidirectional sync"
        return 1
    fi

    # Then sync remote to local (pull changes)
    if ! sync_with_retry "$REMOTE_KONG" "$LOCAL_KONG_DIR" "remote → local"; then
        log "✗ Failed to sync remote to local"
        return 1
    fi

    if [[ "${1:-}" != "dry-run" ]]; then
        log "✓ Bidirectional sync completed successfully"
        notify-send --app-name="Kong Sync" "Sync Complete" "Kong folder synced with Google Drive" -u normal
    fi
}

# Function to check sync status
check_sync_status() {
    log "Checking sync status between local and remote..."

    # Check for differences (this is read-only)
    local changes_found=false

    if rclone check "$LOCAL_KONG_DIR" "$REMOTE_KONG" --one-way 2>/dev/null | grep -q "differences found"; then
        changes_found=true
    fi

    if [ "$changes_found" = true ]; then
        log "Sync status: Changes detected between local and remote"
        notify-send --app-name="Kong Sync" "Changes Detected" "Kong folder needs sync" -u critical
        return 1
    else
        log "Sync status: Local and remote are in sync"
        notify-send --app-name="Kong Sync" "In Sync" "Kong folder is up to date" -u low
        return 0
    fi
}

# Main execution
main() {
    # Rotate logs if needed
    rotate_log

    # Check if rclone is available
    if ! command -v rclone &> /dev/null; then
        log "ERROR: rclone not found in PATH"
        notify-send --app-name="Kong Sync" "Error" "rclone not found" -u critical
        exit 1
    fi

    # Check for lock file
    check_lock

    # Ensure Kong directory exists
    if [ ! -d "$LOCAL_KONG_DIR" ]; then
        log "Creating local Kong directory: $LOCAL_KONG_DIR"
        mkdir -p "$LOCAL_KONG_DIR"
    fi

    # Validate Google Drive access and security
    if ! validate_remote_access; then
        exit 1
    fi

    # Execute based on argument
    case "${1:-sync}" in
        "sync")
            sync_bidirectional
            ;;
        "dry-run")
            sync_bidirectional dry-run
            ;;
        "check")
            check_sync_status
            ;;
        *)
            echo "Usage: $0 [sync|dry-run|check]"
            echo "  sync    - Perform bidirectional sync (default)"
            echo "  dry-run - Show what would be synced without making changes"
            echo "  check   - Check if local and remote are in sync"
            exit 1
            ;;
    esac
}

main "$@"