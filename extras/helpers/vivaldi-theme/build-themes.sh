#!/usr/bin/env nix-shell
#!nix-shell -i bash -p zip

# Vivaldi Theme Builder Script
# Creates importable .zip files from theme directories with generated settings

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🎨 Building Vivaldi Themes..."

# Function to create zip file with generated settings
create_theme_zip() {
    local theme_dir="$1"
    local theme_name="$2"
    local generated_settings="$3"
    
    if [[ ! -d "$theme_dir" ]]; then
        echo "❌ Theme directory '$theme_dir' not found"
        return 1
    fi
    
    if [[ ! -f "$generated_settings" ]]; then
        echo "❌ Generated settings file '$generated_settings' not found"
        echo "💡 Make sure to rebuild your NixOS system first to generate current theme files"
        return 1
    fi
    
    echo "📦 Building $theme_name theme..."
    
    # Create temporary directory for building the zip
    temp_base="temp-build"
    temp_theme_dir="$temp_base/$theme_name"
    mkdir -p "$temp_theme_dir"
    
    # Copy all template files to temp directory
    cp -r "$theme_dir"/* "$temp_theme_dir/"
    
    # Copy generated settings into temp directory (overwriting template settings.json)
    cp "$generated_settings" "$temp_theme_dir/settings.json"
    
    # Create zip file with theme directory structure
    # The zip should contain files directly, not in a subdirectory
    cd "$temp_theme_dir"
    zip -r "../../${theme_name}.zip" .
    cd ../..
    
    # Clean up temp directory
    rm -rf "$temp_base"
    
    echo "✅ Created ${theme_name}.zip with current Stylix colors"
}

# Check if generated directory exists
if [[ ! -d "generated" ]]; then
    echo "❌ Generated directory not found"
    echo "💡 Please rebuild your NixOS system first to generate current theme files"
    exit 1
fi

# Build both themes
create_theme_zip "stylix-dark" "stylix-dark" "generated/stylix-dark-settings.json"
create_theme_zip "stylix-light" "stylix-light" "generated/stylix-light-settings.json"

echo ""
echo "🚀 Theme building complete!"
echo ""
echo "📁 Import files created:"
echo "   • stylix-dark.zip"
echo "   • stylix-light.zip"
echo ""
echo "💡 To import themes:"
echo "   1. Open Vivaldi → Settings → Appearance → Themes"
echo "   2. Click 'Import Theme'"
echo "   3. Select the .zip file"
echo "   4. Apply the imported theme"
echo ""
echo "🔄 Themes will be updated with current Stylix colors on next system rebuild"