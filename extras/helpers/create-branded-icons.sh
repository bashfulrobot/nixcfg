#!/usr/bin/env bash
set -euo pipefail

# Reusable script to create branded app icons by overlaying company logo
# Usage: ./create-branded-icons.sh <logo_path> <source_app> <target_app> [overlay_fraction] [--pristine]
#
# Arguments:
#   logo_path:        Path to the overlay logo (PNG with transparent background)
#   source_app:       Name of source app module (e.g., "gmail-br", "br-drive")
#   target_app:       Name of target app module (e.g., "kong-email", "kong-drive")
#   overlay_fraction: Optional fraction of icon size for overlay (default: 0.5 for 1/4 area)
#   --pristine:       Use pristine backup icons instead of current app icons
#
# Examples:
#   ./create-branded-icons.sh /path/to/logo.png gmail-br kong-email
#   ./create-branded-icons.sh /path/to/logo.png br-drive kong-drive 0.6
#   ./create-branded-icons.sh /path/to/logo.png gcal-br kong-calendar 0.4

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../modules/apps"
PRISTINE_DIR="$SCRIPT_DIR/pristine-icons"
SIZES=(16 32 48 64 96 128 256)

# Default overlay fraction (0.5 = 1/4 of icon area)
DEFAULT_OVERLAY_FRACTION=0.5

# Usage function
usage() {
    cat << EOF
Usage: $0 <logo_path> <source_app> <target_app> [overlay_fraction] [--pristine]

Create branded app icons by overlaying a company logo on existing app icons.

Arguments:
  logo_path         Path to overlay logo (PNG with transparent background)
  source_app        Source app module name (e.g., gmail-br, br-drive)
  target_app        Target app module name (e.g., kong-email, kong-drive)
  overlay_fraction  Logo size as fraction of icon size (default: 0.5 for 1/4 area)
  --pristine        Use pristine backup icons (ensures source icons stay unmodified)

Examples:
  # Create Kong Email icons from Gmail icons
  $0 /home/user/logo.png gmail-br kong-email

  # Create branded Drive icons with smaller logo (40% of icon size)  
  $0 /home/user/logo.png br-drive my-drive 0.4

  # Create branded Calendar icons with larger logo (60% of icon size)
  $0 /home/user/logo.png gcal-br my-calendar 0.6

  # Use pristine backup icons (recommended to preserve originals)
  $0 /home/user/logo.png gmail-br kong-email --pristine

Available source apps in your repo:
$(find "$CONFIG_DIR" -maxdepth 1 -type d -name "*" -exec basename {} \; | grep -v "^apps$" | sort | sed 's/^/  - /')

EOF
}

# Parse arguments
USE_PRISTINE=false
ARGS=()

for arg in "$@"; do
    case $arg in
        --pristine)
            USE_PRISTINE=true
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

# Validate arguments
if [[ ${#ARGS[@]} -lt 3 ]] || [[ ${#ARGS[@]} -gt 4 ]]; then
    echo "Error: Invalid number of arguments"
    usage
    exit 1
fi

LOGO_PATH="${ARGS[0]}"
SOURCE_APP="${ARGS[1]}"
TARGET_APP="${ARGS[2]}"
OVERLAY_FRACTION="${ARGS[3]:-$DEFAULT_OVERLAY_FRACTION}"

# Validate inputs
if [[ ! -f "$LOGO_PATH" ]]; then
    echo "Error: Logo file not found: $LOGO_PATH"
    exit 1
fi

# Determine source directory based on --pristine flag
if [[ "$USE_PRISTINE" == true ]]; then
    SOURCE_ICONS_DIR="$PRISTINE_DIR/$SOURCE_APP"
    if [[ ! -d "$SOURCE_ICONS_DIR" ]]; then
        echo "Error: Pristine backup not found: $SOURCE_ICONS_DIR"
        echo "Available pristine backups:"
        find "$PRISTINE_DIR" -maxdepth 1 -type d ! -name "pristine-icons" -exec basename {} \; 2>/dev/null | sort | sed 's/^/  - /' || echo "  (none)"
        echo ""
        echo "To create a pristine backup: ./helpers/backup-icons.sh $SOURCE_APP"
        exit 1
    fi
else
    SOURCE_ICONS_DIR="$CONFIG_DIR/$SOURCE_APP/icons"
    if [[ ! -d "$SOURCE_ICONS_DIR" ]]; then
        echo "Error: Source app icons not found: $SOURCE_ICONS_DIR"
        echo "Available apps:"
        find "$CONFIG_DIR" -maxdepth 2 -name "icons" -type d | sed 's|.*/\([^/]*\)/icons|\1|' | sort | sed 's/^/  - /'
        exit 1
    fi
fi

TARGET_ICONS_DIR="$CONFIG_DIR/$TARGET_APP/icons"

# Validate overlay fraction
if ! echo "$OVERLAY_FRACTION" | grep -qE '^0\.[0-9]+$|^1\.0*$'; then
    echo "Error: Overlay fraction must be between 0.1 and 1.0 (got: $OVERLAY_FRACTION)"
    exit 1
fi

# Function to create branded icons
create_branded_icons() {
    echo "Creating branded icons for $TARGET_APP..."
    echo "  Source: $SOURCE_APP"
    if [[ "$USE_PRISTINE" == true ]]; then
        echo "  Using: Pristine backup icons (originals preserved)"
    else
        echo "  Using: Current app icons"
    fi
    echo "  Logo: $(basename "$LOGO_PATH")"
    echo "  Overlay size: ${OVERLAY_FRACTION} of icon size"
    echo ""
    
    # Ensure target directory exists
    mkdir -p "$TARGET_ICONS_DIR"
    
    for size in "${SIZES[@]}"; do
        local source_icon="$SOURCE_ICONS_DIR/${size}.png"
        local target_icon="$TARGET_ICONS_DIR/${size}.png"
        
        if [[ -f "$source_icon" ]]; then
            # Get actual dimensions of the source icon
            local actual_dimensions
            actual_dimensions=$(nix-shell -p imagemagick --run "identify -format '%wx%h' '$source_icon'")
            local actual_width actual_height
            actual_width=${actual_dimensions%x*}
            actual_height=${actual_dimensions#*x}
            
            echo "  Processing ${actual_width}x${actual_height} icon..."
            
            # Calculate overlay size based on smaller dimension to ensure it fits
            local base_size=$(( actual_width < actual_height ? actual_width : actual_height ))
            local overlay_size
            overlay_size=$(nix-shell -p bc --run "echo \"$base_size * $OVERLAY_FRACTION\" | bc -l | xargs printf \"%.0f\"")
            
            # Position at bottom right corner based on actual dimensions
            local x_pos=$((actual_width - overlay_size))
            local y_pos=$((actual_height - overlay_size))
            
            # Use nix-shell to ensure ImageMagick is available
            nix-shell -p imagemagick bc --run "
                magick '$source_icon' \\
                    \\( '$LOGO_PATH' -resize ${overlay_size}x${overlay_size} \\) \\
                    -gravity none -geometry +${x_pos}+${y_pos} \\
                    -composite '$target_icon'
            " 2>/dev/null
            
            echo "    ✓ Generated ${actual_width}x${actual_height} with ${overlay_size}x${overlay_size} overlay at position +${x_pos}+${y_pos}"
        else
            echo "    ⚠ Warning: Source icon $source_icon not found"
        fi
    done
    
    echo ""
    echo "✅ Branded icon generation complete!"
    echo "📁 Generated icons: $TARGET_ICONS_DIR"
}

# Check if bc is available for floating point calculations
if ! command -v bc >/dev/null 2>&1; then
    echo "Note: Using nix-shell to provide 'bc' for calculations..."
fi

# Main execution
echo "🏷️  Branded Icon Generator"
echo "=========================="
create_branded_icons

# Show what was created
echo ""
echo "Generated files:"
find "$TARGET_ICONS_DIR" -name "*.png" | sort | sed 's/^/  📄 /'