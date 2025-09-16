#!/usr/bin/env bash

# COSMIC Theme Builder Script
# Creates importable .ron files from stylix-generated themes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🌌 Building COSMIC Themes from Stylix colors..."

# Function to create theme file from generated source
create_theme_file() {
    local generated_file="$1"
    local output_file="$2"
    local theme_name="$3"
    
    if [[ ! -f "$generated_file" ]]; then
        echo "❌ Generated theme file '$generated_file' not found"
        echo "💡 Make sure to rebuild your NixOS system first to generate current theme files"
        return 1
    fi
    
    echo "📦 Building $theme_name theme..."
    
    # Copy generated theme file to current directory as importable .ron file
    cp "$generated_file" "$output_file"
    
    echo "✅ Created $output_file with current Stylix colors"
}

# Check if generated directory exists
if [[ ! -d "generated" ]]; then
    echo "❌ Generated directory not found"
    echo "💡 Please rebuild your NixOS system first to generate current theme files"
    exit 1
fi

# Build both themes
create_theme_file "generated/stylix-dark.ron" "Stylix-dark.ron" "stylix-dark"
create_theme_file "generated/stylix-light.ron" "Stylix-light.ron" "stylix-light"

echo ""
echo "🚀 Theme building complete!"
echo ""
echo "📁 Import files created:"
echo "   • Stylix-dark.ron"
echo "   • Stylix-light.ron"
echo ""
echo "💡 To import themes:"
echo "   1. Open COSMIC Settings → Appearance → Manage Themes"
echo "   2. Click 'Import Theme'"
echo "   3. Select the .ron file"
echo "   4. Apply the imported theme"
echo ""
echo "🔄 Themes will be updated with current Stylix colors on next system rebuild"