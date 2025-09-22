#!/usr/bin/env bash
# Update COSMIC packages using cached hash file
# Usage: ./update-pins.sh [--dry-run]

set -uo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
BUILD_DIR="$REPO_ROOT/modules/desktops/cosmic/build/pkgs"
CACHE_FILE="$SCRIPT_DIR/latest-hashes.json"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed"
    echo "   Install it with: nix shell nixpkgs#jq"
    exit 1
fi

# Check if cache file exists
if [[ ! -f "$CACHE_FILE" ]]; then
    echo "❌ Cache file not found: $CACHE_FILE"
    echo "   Run './fetch-latest-hashes.sh' first to create the cache"
    exit 1
fi

# Parse command line arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🔍 DRY RUN MODE - No files will be modified"
    echo
fi

# Read cache info
fetched_at=$(jq -r '.fetched_at' "$CACHE_FILE")
echo "📁 Using cached hashes from: $fetched_at"
echo

# Get list of packages from cache
packages=$(jq -r '.packages | keys[]' "$CACHE_FILE")

update_count=0
packages_checked=0

# Process each package
while IFS= read -r pkg; do
    if [[ -f "$BUILD_DIR/$pkg/default.nix" ]]; then
        # Get current commit from file
        current=$(grep -o 'rev = "[^"]*"' "$BUILD_DIR/$pkg/default.nix" | cut -d'"' -f2)

        # Get latest commit from cache
        latest=$(jq -r ".packages.\"$pkg\"" "$CACHE_FILE")

        ((packages_checked++))

        if [[ "$latest" == "null" ]]; then
            echo "📦 $pkg: ${current:0:8} (⚠️  no cached hash available)"
        elif [[ "$current" != "$latest" ]]; then
            echo "📦 $pkg: ${current:0:8} → ${latest:0:8} (UPDATE NEEDED)"

            if [[ "$DRY_RUN" == "false" ]]; then
                # Update the rev field
                sed -i "s|rev = \"$current\"|rev = \"$latest\"|g" "$BUILD_DIR/$pkg/default.nix"
                echo "   ✓ Updated successfully"
                ((update_count++))
            fi
        else
            echo "📦 $pkg: ${current:0:8} (up to date)"
        fi
    else
        echo "⚠️  $pkg: package file not found"
    fi
done <<< "$packages"

echo
echo "📊 Summary:"
echo "   📦 Packages checked: $packages_checked"

if [[ "$DRY_RUN" == "true" ]]; then
    needed_updates=$(jq -r '
        .packages |
        to_entries |
        map(select(.value != null)) |
        length
    ' "$CACHE_FILE" || echo "0")
    echo "   🔄 Would update: $needed_updates package(s)"
    echo
    echo "💡 Run without --dry-run to apply updates"
elif [[ $update_count -gt 0 ]]; then
    echo "   ✅ Updated: $update_count package(s)"
    echo
    echo "🚀 Next steps:"
    echo "   1. Run 'just cosmic-cache' to build and cache packages"
    echo "   2. If you get hash mismatches, use '../fix-cosmic-hash.sh'"
    echo "   3. Run 'just rebuild' to update your system"
else
    echo "   ✅ All packages are already up to date!"
fi