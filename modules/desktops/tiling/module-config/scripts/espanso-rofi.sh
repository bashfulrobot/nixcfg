#!/usr/bin/env bash

# kill yad to not interfere with this binds
pkill yad || true

# check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# define the config files
espanso_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/espanso"
rofi_theme="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-4/style-4.rasi"
r_override="entry{placeholder:'Search Espanso Shortcuts...';}"
msg='☣️ NOTE ☣️: Clicking with Mouse or Pressing ENTER will have NO function'

# function to extract espanso matches from yaml files
extract_matches() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Extract trigger and replace pairs from YAML
        python3 -c "
import yaml
import sys

try:
    with open('$file', 'r') as f:
        data = yaml.safe_load(f)
    
    if 'matches' in data:
        for match in data['matches']:
            if 'trigger' in match and 'replace' in match:
                trigger = match['trigger']
                replace = match['replace']
                # Truncate long replacements for display
                if len(replace) > 50:
                    replace = replace[:47] + '...'
                print(f'{trigger} → {replace}')
except Exception as e:
    pass
" 2>/dev/null
    fi
}

# collect all espanso definitions
espanso_defs=""

# check for espanso config directory
if [[ -d "$espanso_config_dir" ]]; then
    # look for match files in config directory
    for yaml_file in "$espanso_config_dir/match"/*.yml "$espanso_config_dir/match"/*.yaml; do
        if [[ -f "$yaml_file" ]]; then
            file_defs=$(extract_matches "$yaml_file")
            if [[ -n "$file_defs" ]]; then
                basename_file=$(basename "$yaml_file" .yml)
                basename_file=$(basename "$basename_file" .yaml)
                espanso_defs+="=== $basename_file ===$'\n'$file_defs$'\n'$'\n'"
            fi
        fi
    done
fi

# fallback: extract from our nix configuration if espanso config not found
if [[ -z "$espanso_defs" ]]; then
    nix_espanso_file="/home/dustin/dev/nix/nixcfg/modules/cli/espanso/default.nix"
    if [[ -f "$nix_espanso_file" ]]; then
        # Extract trigger/replace pairs from nix file
        espanso_defs=$(grep -A 1 'trigger = ' "$nix_espanso_file" | grep -E '(trigger|replace)' | \
            sed 's/.*trigger = "\([^"]*\)".*/\1/' | \
            sed 's/.*replace = "\([^"]*\)".*/→ \1/' | \
            paste - - | \
            sed 's/\t/ /')
        
        if [[ -n "$espanso_defs" ]]; then
            espanso_defs="=== From NixOS Config ===$'\n'$espanso_defs"
        fi
    fi
fi

# check for any definitions to display
if [[ -z "$espanso_defs" ]]; then
    echo "No espanso definitions found."
    exit 1
fi

# use rofi to display the espanso definitions
echo -e "$espanso_defs" | rofi -dmenu -i -theme-str "$r_override" -config "$rofi_theme" -mesg "$msg"