#!/usr/bin/env bash
# Fetch latest commit hashes from pop-os repositories and cache them locally
# Usage: ./fetch-latest-hashes.sh

set -uo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_FILE="$SCRIPT_DIR/latest-hashes.json"

# Check if required tools are available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is required but not installed"
    echo "   Install it with: nix shell nixpkgs#gh"
    exit 1
fi

if ! command -v gum &> /dev/null; then
    echo "❌ gum is required but not installed"
    echo "   Install it with: nix shell nixpkgs#gum"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed"
    echo "   Install it with: nix shell nixpkgs#jq"
    exit 1
fi

# List of COSMIC packages to fetch
PACKAGES=(
    cosmic-applets
    cosmic-applibrary
    cosmic-bg
    cosmic-comp
    cosmic-edit
    cosmic-files
    cosmic-greeter
    cosmic-icons
    cosmic-idle
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-player
    cosmic-protocols
    cosmic-randr
    cosmic-screenshot
    cosmic-session
    cosmic-settings
    cosmic-settings-daemon
    cosmic-store
    cosmic-term
    cosmic-wallpapers
    cosmic-workspaces-epoch
    xdg-desktop-portal-cosmic
)

echo "🔍 Fetching latest commits from pop-os repositories..."
echo "📁 Target cache file: $CACHE_FILE"
echo

# Use temporary file to build JSON - only move to final location on complete success
TEMP_FILE="$CACHE_FILE.tmp"

successful_fetches=0
total_packages=${#PACKAGES[@]}
declare -a fetch_results

# Fetch each package and store results
for i in "${!PACKAGES[@]}"; do
    pkg="${PACKAGES[$i]}"

    # Handle special case for xdg-desktop-portal-cosmic
    pkg_name="$pkg"
    [[ "$pkg" == "xdg-desktop-portal-cosmic" ]] && pkg_name="xdg-desktop-portal-cosmic"

    # Handle repositories with different default branches
    branch="master"
    [[ "$pkg" == "cosmic-protocols" ]] && branch="main"

    # Fetch latest commit with spinner
    if latest=$(gum spin --spinner dot --title "Fetching latest commit for $pkg..." -- \
        gh api "repos/pop-os/$pkg_name/commits/$branch" --paginate=false --jq '.sha'); then
        echo "📦 $pkg: ${latest:0:8} ✓"
        fetch_results[$i]="$latest"
        ((successful_fetches++))
    else
        echo "📦 $pkg: ❌ failed to fetch"
        fetch_results[$i]=""
    fi
done

echo
echo "📊 Fetch Results:"
echo "   ✅ Successfully fetched: $successful_fetches/$total_packages packages"

# Only update cache file if ALL packages were successfully fetched
if [[ $successful_fetches -eq $total_packages ]]; then
    # Start building JSON object in temp file
    echo "{" > "$TEMP_FILE"
    echo "  \"fetched_at\": \"$(date -Iseconds)\"," >> "$TEMP_FILE"
    echo "  \"packages\": {" >> "$TEMP_FILE"

    # Write all results to temp file
    for i in "${!PACKAGES[@]}"; do
        pkg="${PACKAGES[$i]}"
        latest="${fetch_results[$i]}"

        if [[ $i -eq $((total_packages - 1)) ]]; then
            echo "    \"$pkg\": \"$latest\"" >> "$TEMP_FILE"
        else
            echo "    \"$pkg\": \"$latest\"," >> "$TEMP_FILE"
        fi
    done

    # Close JSON object
    echo "  }" >> "$TEMP_FILE"
    echo "}" >> "$TEMP_FILE"

    # Move temp file to final location
    mv "$TEMP_FILE" "$CACHE_FILE"

    echo "   ✅ Cache file updated: $CACHE_FILE"
    echo
    echo "🚀 Next step: Run './update-pins.sh' to apply updates"
else
    # Clean up temp file if it exists
    rm -f "$TEMP_FILE"

    failed_count=$((total_packages - successful_fetches))
    echo "   ❌ Failed to fetch: $failed_count packages"
    echo "   ⚠️  Cache file NOT updated (partial failure)"
    echo
    echo "💡 Fix network/auth issues and try again to update cache"
    exit 1
fi