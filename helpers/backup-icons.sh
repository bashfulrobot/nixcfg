#!/usr/bin/env bash
set -euo pipefail

# Script to backup pristine app icons before they get modified with overlays
# Usage: ./backup-icons.sh [app_name] or ./backup-icons.sh --all

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../modules/apps"
PRISTINE_DIR="$SCRIPT_DIR/pristine-icons"

usage() {
    cat << EOF
Usage: $0 [app_name] | --all | --list | --restore <app_name>

Backup pristine app icons before applying overlays.

Commands:
  $0 gmail-br           Backup icons for specific app
  $0 --all             Backup icons for all apps
  $0 --list            List available apps and backup status
  $0 --restore gmail-br Restore original icons for specific app

Examples:
  # Backup Gmail icons before creating Kong Email
  $0 gmail-br
  
  # Backup all app icons
  $0 --all
  
  # Restore Gmail to original state
  $0 --restore gmail-br

EOF
}

backup_app_icons() {
    local app_name="$1"
    local source_dir="$CONFIG_DIR/$app_name/icons"
    local backup_dir="$PRISTINE_DIR/$app_name"
    
    if [[ ! -d "$source_dir" ]]; then
        echo "❌ Error: App icons not found: $source_dir"
        return 1
    fi
    
    if [[ -d "$backup_dir" ]]; then
        echo "📁 Backup already exists for $app_name"
        read -p "   Overwrite existing backup? [y/N]: " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "   Skipping $app_name"
            return 0
        fi
        rm -rf "$backup_dir"
    fi
    
    echo "💾 Backing up $app_name icons..."
    mkdir -p "$backup_dir"
    cp -r "$source_dir"/* "$backup_dir/"
    
    local icon_count
    icon_count=$(find "$backup_dir" -name "*.png" | wc -l)
    echo "   ✅ Backed up $icon_count icons to pristine-icons/$app_name"
}

restore_app_icons() {
    local app_name="$1"
    local backup_dir="$PRISTINE_DIR/$app_name"
    local target_dir="$CONFIG_DIR/$app_name/icons"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "❌ Error: No backup found for $app_name"
        echo "   Available backups:"
        find "$PRISTINE_DIR" -maxdepth 1 -type d ! -name "pristine-icons" -exec basename {} \; | sort | sed 's/^/     - /'
        return 1
    fi
    
    if [[ ! -d "$target_dir" ]]; then
        echo "❌ Error: Target app directory not found: $target_dir"
        return 1
    fi
    
    echo "🔄 Restoring $app_name icons from backup..."
    rm -rf "$target_dir"/*
    cp -r "$backup_dir"/* "$target_dir/"
    
    local icon_count
    icon_count=$(find "$target_dir" -name "*.png" | wc -l)
    echo "   ✅ Restored $icon_count pristine icons to $app_name"
}

list_apps_and_backups() {
    echo "📋 Apps and Backup Status"
    echo "========================"
    
    # Find all apps with icons
    local apps
    mapfile -t apps < <(find "$CONFIG_DIR" -maxdepth 2 -name "icons" -type d | sed 's|.*/\([^/]*\)/icons|\1|' | sort)
    
    for app in "${apps[@]}"; do
        local backup_dir="$PRISTINE_DIR/$app"
        local source_dir="$CONFIG_DIR/$app/icons"
        
        if [[ -d "$backup_dir" ]]; then
            local backup_count
            backup_count=$(find "$backup_dir" -name "*.png" 2>/dev/null | wc -l)
            echo "✅ $app (backup: ${backup_count} icons)"
        else
            local source_count
            source_count=$(find "$source_dir" -name "*.png" 2>/dev/null | wc -l)
            echo "❌ $app (no backup, source: ${source_count} icons)"
        fi
    done
    
    echo ""
    echo "💡 Tips:"
    echo "   - Backup apps before applying overlays: $0 <app_name>"
    echo "   - Backup all apps at once: $0 --all"
    echo "   - Restore original icons: $0 --restore <app_name>"
}

backup_all_apps() {
    echo "🗂️  Backing up all app icons..."
    echo ""
    
    local apps
    mapfile -t apps < <(find "$CONFIG_DIR" -maxdepth 2 -name "icons" -type d | sed 's|.*/\([^/]*\)/icons|\1|' | sort)
    
    local backed_up=0
    local skipped=0
    
    for app in "${apps[@]}"; do
        if backup_app_icons "$app"; then
            ((backed_up++))
        else
            ((skipped++))
        fi
        echo ""
    done
    
    echo "📊 Summary:"
    echo "   ✅ Backed up: $backed_up apps"
    echo "   ⏭️  Skipped: $skipped apps"
}

# Main execution
if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

case "${1:-}" in
    --all)
        backup_all_apps
        ;;
    --list)
        list_apps_and_backups
        ;;
    --restore)
        if [[ $# -ne 2 ]]; then
            echo "❌ Error: --restore requires an app name"
            usage
            exit 1
        fi
        restore_app_icons "$2"
        ;;
    --help|-h)
        usage
        ;;
    *)
        if [[ -n "${1:-}" ]]; then
            backup_app_icons "$1"
        else
            usage
        fi
        ;;
esac