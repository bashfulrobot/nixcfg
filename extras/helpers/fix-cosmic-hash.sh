#!/usr/bin/env bash
# Helper script to quickly fix COSMIC package hash mismatches

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <old-hash> <new-hash>"
    echo "Example: $0 'sha256-eVQvc+gywiVLRnvpG+pypfLfiZIm/QLZXekg3PEI898=' 'sha256-3bifxzna1STSybQPx7BWIlWIThsjCN5gHK2GiGCC/L4='"
    exit 1
fi

OLD_HASH="$1"
NEW_HASH="$2"
BUILD_DIR="/home/dustin/dev/nix/nixcfg/modules/desktops/cosmic/build/pkgs"

echo "🔍 Searching for hash: $OLD_HASH"

# Find the file containing the old hash
FOUND_FILE=$(find "$BUILD_DIR" -name "*.nix" -exec grep -l "$OLD_HASH" {} \; | head -1)

if [[ -z "$FOUND_FILE" ]]; then
    echo "❌ Hash not found in any cosmic build files"
    exit 1
fi

echo "📝 Found in: $FOUND_FILE"
echo "🔄 Updating hash..."

# Replace the hash
sed -i "s|$OLD_HASH|$NEW_HASH|g" "$FOUND_FILE"

echo "✅ Hash updated successfully!"
echo "🚀 You can now run 'just build' or 'just cosmic-cache' again"