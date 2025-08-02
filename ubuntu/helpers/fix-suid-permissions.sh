#!/usr/bin/env bash

# Fix SUID sandbox permissions for applications that require them
# This script dynamically finds chrome-sandbox binaries in /nix/store and sets proper permissions

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Applications that need chrome-sandbox SUID permissions
readonly SUID_APPS=(
    "1password"
    "chromium"
    "chrome"
    "google-chrome"
    "brave-browser"
    "vivaldi"
    "opera"
    "electron"
)

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

fix_chrome_sandbox_permissions() {
    local fixed_count=0
    local total_found=0
    
    log_info "Searching for chrome-sandbox binaries in /nix/store..."
    
    # Find all chrome-sandbox binaries for our target applications
    for app in "${SUID_APPS[@]}"; do
        log_info "Checking for ${app} chrome-sandbox binaries..."
        
        # Use find to locate chrome-sandbox binaries for this app
        # Look for paths containing the app name
        while IFS= read -r -d '' sandbox_path; do
            total_found=$((total_found + 1))
            log_info "Found: ${sandbox_path}"
            
            # Check current permissions
            current_perms=$(stat -c "%a" "$sandbox_path" 2>/dev/null || echo "unknown")
            current_owner=$(stat -c "%U" "$sandbox_path" 2>/dev/null || echo "unknown")
            
            log_info "Current permissions: ${current_owner}:${current_perms}"
            
            # Fix permissions if needed
            if [[ "$current_owner" != "root" ]] || [[ "$current_perms" != "4755" ]]; then
                log_info "Fixing permissions for: ${sandbox_path}"
                
                if sudo chown root:root "$sandbox_path" && sudo chmod 4755 "$sandbox_path"; then
                    log_success "Fixed permissions for: ${sandbox_path}"
                    fixed_count=$((fixed_count + 1))
                else
                    log_error "Failed to fix permissions for: ${sandbox_path}"
                fi
            else
                log_success "Permissions already correct for: ${sandbox_path}"
                fixed_count=$((fixed_count + 1))
            fi
            
        done < <(find /nix/store -path "*${app}*" -name "chrome-sandbox" -type f -print0 2>/dev/null || true)
    done
    
    # Summary
    if [[ $total_found -eq 0 ]]; then
        log_warning "No chrome-sandbox binaries found for any target applications"
    else
        log_info "Summary: Found ${total_found} chrome-sandbox binaries, fixed ${fixed_count}"
        
        if [[ $fixed_count -eq $total_found ]]; then
            log_success "All chrome-sandbox binaries have correct permissions"
        else
            log_warning "Some chrome-sandbox binaries may still have incorrect permissions"
        fi
    fi
}

main() {
    log_info "Starting SUID sandbox permissions fix..."
    
    # Check if running as non-root (we need sudo for chown/chmod)
    if [[ $EUID -eq 0 ]]; then
        log_warning "Running as root. Consider running as regular user with sudo access."
    fi
    
    # Check if we have sudo access
    if ! sudo -n true 2>/dev/null; then
        log_info "This script requires sudo access to fix permissions"
        sudo -v || {
            log_error "Failed to obtain sudo access"
            exit 1
        }
    fi
    
    fix_chrome_sandbox_permissions
    
    log_success "SUID sandbox permissions fix completed"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi