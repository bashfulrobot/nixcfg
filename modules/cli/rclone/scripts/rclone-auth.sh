#!/usr/bin/env bash

# Script to help with rclone authentication and token management

set -euo pipefail

# Configuration
CONFIG_DIR="${HOME}/.config/rclone"
CONFIG_FILE="${CONFIG_DIR}/rclone.conf"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Function to check rclone authentication
check_auth() {
    print_status "Checking rclone authentication status..."

    if ! command -v rclone &> /dev/null; then
        print_error "rclone not found in PATH"
        return 1
    fi

    # Check if config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        print_warning "rclone config file not found at $CONFIG_FILE"
        return 1
    fi

    # Try to list Google Drive root
    if rclone lsd gdrive: &> /dev/null; then
        print_status "✓ rclone authentication is working"
        return 0
    else
        print_warning "rclone authentication failed or expired"
        return 1
    fi
}

# Function to fix authentication
fix_auth() {
    print_status "Fixing rclone authentication..."

    # Ensure config directory exists
    mkdir -p "$CONFIG_DIR"

    # Check if we need to create/update config
    if [ ! -f "$CONFIG_FILE" ]; then
        print_warning "Creating new rclone config..."
        rclone config create gdrive drive --all
    else
        print_status "Testing existing configuration..."
        if ! rclone lsd gdrive: &> /dev/null; then
            print_warning "Existing config not working, running interactive setup..."
            rclone config
        fi
    fi

    # Verify authentication works
    if check_auth; then
        print_status "✓ Authentication fixed successfully!"

        # Test with a simple operation
        print_status "Testing basic Google Drive access..."
        rclone ls gdrive: --max-depth 1 | head -5

        return 0
    else
        print_error "Authentication still not working"
        return 1
    fi
}

# Function to show authentication info
show_auth_info() {
    print_status "Authentication Information:"
    echo "Config file: $CONFIG_FILE"
    echo "Remote name: gdrive"
    echo ""

    if check_auth; then
        print_status "Current status: ✓ Authenticated"

        # Show some basic info
        echo ""
        print_status "Google Drive root contents (first 5 items):"
        rclone ls gdrive: --max-depth 1 | head -5
    else
        print_warning "Current status: ✗ Not authenticated"
    fi
}

# Function to clear authentication (if needed)
clear_auth() {
    print_warning "Clearing rclone authentication..."

    if [ -f "$CONFIG_FILE" ]; then
        mv "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%s)"
        print_status "Config file backed up and removed"
    fi

    # Also remove any token cache
    rm -rf "${HOME}/.cache/rclone" 2>/dev/null || true
    print_status "Token cache cleared"
}

# Main function
main() {
    echo "rclone Authentication Helper"
    echo "============================"
    echo ""

    case "${1:-check}" in
        "check")
            check_auth
            ;;
        "fix")
            fix_auth
            ;;
        "info")
            show_auth_info
            ;;
        "clear")
            clear_auth
            ;;
        "status")
            show_auth_info
            ;;
        *)
            echo "Usage: $0 [check|fix|info|clear]"
            echo ""
            echo "Commands:"
            echo "  check  - Check if authentication is working (default)"
            echo "  fix    - Run interactive authentication setup"
            echo "  info   - Show authentication status and info"
            echo "  clear  - Clear all authentication data"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"