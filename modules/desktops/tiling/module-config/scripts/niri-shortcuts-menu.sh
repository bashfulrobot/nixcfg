#!/usr/bin/env bash

# Niri Keyboard Shortcuts Menu
# Shows all keyboard shortcuts in fuzzel with descriptions and allows execution

# Define shortcuts with descriptions
declare -A shortcuts=(
    # Application Launchers
    ["Super+Space"]="Launch application launcher (fuzzel)"
    ["Super+T"]="Open terminal (ghostty)"
    ["Super+Return"]="Open terminal (ghostty)"
    ["Super+Z"]="Open file manager (nautilus)"
    ["Super+Shift+Space"]="Open AI chat (Alpaca)"
    
    # Window Management
    ["Super+Q"]="Close current window"
    ["Super+Shift+Q"]="Quit niri session"
    ["Super+F"]="Toggle fullscreen"
    ["Super+Comma"]="Consume window into column"
    ["Super+Period"]="Expel window from column"
    ["Ctrl+Shift+Space"]="Toggle window floating"
    ["Super+Shift+W"]="Toggle windowed fullscreen"
    
    # Navigation - Arrow Keys
    ["Super+Up"]="Focus window up"
    ["Super+Down"]="Focus window down"
    ["Super+Left"]="Focus column left"
    ["Super+Right"]="Focus column right"
    ["Super+Shift+Left"]="Move column left"
    ["Super+Shift+Right"]="Move column right"
    
    # Navigation - Vim Keys
    ["Super+K"]="Focus window up (vim-style)"
    ["Super+J"]="Focus window down (vim-style)"
    ["Super+H"]="Focus column left (vim-style)"
    ["Super+L"]="Focus column right (vim-style)"
    ["Super+Shift+H"]="Move column left (vim-style)"
    
    # Workspace Navigation
    ["Super+1"]="Switch to workspace 1"
    ["Super+2"]="Switch to workspace 2"
    ["Super+3"]="Switch to workspace 3"
    ["Super+4"]="Switch to workspace 4"
    ["Super+5"]="Switch to workspace 5"
    ["Super+6"]="Switch to workspace 6"
    ["Super+7"]="Switch to workspace 7"
    ["Super+8"]="Switch to workspace 8"
    ["Super+9"]="Switch to workspace 9"
    ["Super+Page_Up"]="Focus workspace up"
    ["Super+Page_Down"]="Focus workspace down"
    
    # Move to Workspaces
    ["Super+Shift+1"]="Move window to workspace 1"
    ["Super+Shift+2"]="Move window to workspace 2"
    ["Super+Shift+3"]="Move window to workspace 3"
    ["Super+Shift+4"]="Move window to workspace 4"
    ["Super+Shift+5"]="Move window to workspace 5"
    ["Super+Shift+6"]="Move window to workspace 6"
    ["Super+Shift+7"]="Move window to workspace 7"
    ["Super+Shift+8"]="Move window to workspace 8"
    ["Super+Shift+9"]="Move window to workspace 9"
    ["Super+Shift+Page_Up"]="Move column to workspace up"
    ["Super+Shift+Page_Down"]="Move column to workspace down"
    
    # Monitor Management
    ["Super+Control+Up"]="Move column to monitor up"
    ["Super+Control+Down"]="Move column to monitor down"
    ["Super+Control+Left"]="Move column to monitor left"
    ["Super+Control+Right"]="Move column to monitor right"
    
    # Layout Controls
    ["Super+R"]="Switch preset column width"
    ["Super+Shift+R"]="Switch preset window height"
    ["Ctrl+Down"]="Toggle overview"
    
    # Screenshots
    ["Print"]="Screenshot current window"
    ["Super+Print"]="Screenshot entire screen"
    ["Super+Shift+Print"]="Screenshot entire screen"
    ["Super+Shift+S"]="Screenshot selection area"
    
    # System Tools
    ["Super+C"]="Clipboard history (cliphist)"
    ["Super+E"]="Emoji picker (bemoji)"
    ["Super+P"]="Color picker (hyprpicker)"
    ["Super+N"]="Toggle notification center"
    ["Super+Backslash"]="1Password quick access"
    
    # Media Controls
    ["XF86AudioPlay"]="Play/pause media"
    ["XF86AudioPause"]="Play/pause media"
    ["XF86AudioNext"]="Next track"
    ["XF86AudioPrev"]="Previous track"
    ["XF86AudioRaiseVolume"]="Increase volume"
    ["XF86AudioLowerVolume"]="Decrease volume"
    ["XF86AudioMute"]="Toggle mute"
    ["XF86AudioMicMute"]="Toggle microphone mute"
    
    # Brightness
    ["XF86MonBrightnessUp"]="Increase brightness"
    ["XF86MonBrightnessDown"]="Decrease brightness"
    
    # System Monitoring (SwayOSD)
    ["Super+F1"]="Show battery status"
    ["Super+F2"]="Show memory usage"
    ["Super+F3"]="Show CPU temperature"
    ["Super+F4"]="Show disk usage"
    ["Super+Shift+F1"]="Show microphone volume"
    ["Super+Shift+F2"]="Show WiFi strength"
    
    # Screencasting
    ["Super+Shift+C"]="Set dynamic cast window"
    ["Super+Shift+M"]="Set dynamic cast monitor"
    ["Super+Shift+Escape"]="Clear dynamic cast target"
    
    # Help
    ["Super+Shift+Slash"]="Show this keyboard shortcuts menu"
    
    # Other
    ["Num_Lock"]="Toggle num lock"
)

# Define actions for each shortcut
declare -A actions=(
    ["Super+Space"]="fuzzel"
    ["Super+T"]="ghostty"
    ["Super+Return"]="ghostty"
    ["Super+Z"]="nautilus"
    ["Super+Shift+Space"]="com.jeffser.Alpaca --live-chat"
    ["Super+Q"]="niri msg action close-window"
    ["Super+Shift+Q"]="niri msg action quit"
    ["Super+F"]="niri msg action fullscreen-window"
    ["Super+Comma"]="niri msg action consume-window-into-column"
    ["Super+Period"]="niri msg action expel-window-from-column"
    ["Ctrl+Shift+Space"]="niri msg action toggle-window-floating"
    ["Super+Shift+W"]="niri msg action toggle-windowed-fullscreen"
    ["Super+Up"]="niri msg action focus-window-up"
    ["Super+Down"]="niri msg action focus-window-down"
    ["Super+Left"]="niri msg action focus-column-left"
    ["Super+Right"]="niri msg action focus-column-right"
    ["Super+Shift+Left"]="niri msg action move-column-left"
    ["Super+Shift+Right"]="niri msg action move-column-right"
    ["Super+K"]="niri msg action focus-window-up"
    ["Super+J"]="niri msg action focus-window-down"
    ["Super+H"]="niri msg action focus-column-left"
    ["Super+L"]="niri msg action focus-column-right"
    ["Super+Shift+H"]="niri msg action move-column-left"
    ["Super+1"]="niri msg action focus-workspace 1"
    ["Super+2"]="niri msg action focus-workspace 2"
    ["Super+3"]="niri msg action focus-workspace 3"
    ["Super+4"]="niri msg action focus-workspace 4"
    ["Super+5"]="niri msg action focus-workspace 5"
    ["Super+6"]="niri msg action focus-workspace 6"
    ["Super+7"]="niri msg action focus-workspace 7"
    ["Super+8"]="niri msg action focus-workspace 8"
    ["Super+9"]="niri msg action focus-workspace 9"
    ["Super+Page_Up"]="niri msg action focus-workspace-up"
    ["Super+Page_Down"]="niri msg action focus-workspace-down"
    ["Super+Shift+1"]="niri msg action move-column-to-workspace 1"
    ["Super+Shift+2"]="niri msg action move-column-to-workspace 2"
    ["Super+Shift+3"]="niri msg action move-column-to-workspace 3"
    ["Super+Shift+4"]="niri msg action move-column-to-workspace 4"
    ["Super+Shift+5"]="niri msg action move-column-to-workspace 5"
    ["Super+Shift+6"]="niri msg action move-column-to-workspace 6"
    ["Super+Shift+7"]="niri msg action move-column-to-workspace 7"
    ["Super+Shift+8"]="niri msg action move-column-to-workspace 8"
    ["Super+Shift+9"]="niri msg action move-column-to-workspace 9"
    ["Super+Shift+Page_Up"]="niri msg action move-column-to-workspace-up"
    ["Super+Shift+Page_Down"]="niri msg action move-column-to-workspace-down"
    ["Super+Control+Up"]="niri msg action move-column-to-monitor-up"
    ["Super+Control+Down"]="niri msg action move-column-to-monitor-down"
    ["Super+Control+Left"]="niri msg action move-column-to-monitor-left"
    ["Super+Control+Right"]="niri msg action move-column-to-monitor-right"
    ["Super+R"]="niri msg action switch-preset-column-width"
    ["Super+Shift+R"]="niri msg action switch-preset-window-height"
    ["Ctrl+Down"]="niri msg action toggle-overview"
    ["Print"]="niri msg action screenshot-window"
    ["Super+Print"]="niri msg action screenshot"
    ["Super+Shift+Print"]="niri msg action screenshot"
    ["Super+Shift+S"]="bash -c 'grim -g \"\$(slurp)\" - | wl-copy'"
    ["Super+C"]="bash -c 'cliphist list | fuzzel --dmenu --prompt=\"Copy to Clipboard:\" | cliphist decode | wl-copy'"
    ["Super+E"]="bemoji"
    ["Super+P"]="hyprpicker"
    ["Super+N"]="swaync-client -t"
    ["Super+Backslash"]="1password --quick-access"
    ["XF86AudioPlay"]="swayosd-client --player-status play-pause"
    ["XF86AudioPause"]="swayosd-client --player-status play-pause"
    ["XF86AudioNext"]="swayosd-client --player-status next"
    ["XF86AudioPrev"]="swayosd-client --player-status previous"
    ["XF86AudioRaiseVolume"]="swayosd-client --output-volume raise"
    ["XF86AudioLowerVolume"]="swayosd-client --output-volume lower"
    ["XF86AudioMute"]="swayosd-client --output-volume mute-toggle"
    ["XF86AudioMicMute"]="swayosd-client --input-volume mute-toggle"
    ["XF86MonBrightnessUp"]="swayosd-client --brightness raise"
    ["XF86MonBrightnessDown"]="swayosd-client --brightness lower"
    ["Super+F1"]="swayosd-custom battery"
    ["Super+F2"]="swayosd-custom memory-usage"
    ["Super+F3"]="swayosd-custom cpu-temp"
    ["Super+F4"]="swayosd-custom disk-usage"
    ["Super+Shift+F1"]="swayosd-custom microphone-volume"
    ["Super+Shift+F2"]="swayosd-custom wifi-strength"
    ["Super+Shift+C"]="niri msg action set-dynamic-cast-window"
    ["Super+Shift+M"]="niri msg action set-dynamic-cast-monitor"
    ["Super+Shift+Escape"]="niri msg action clear-dynamic-cast-target"
    ["Super+Shift+Slash"]="/home/dustin/dev/nix/nixcfg/modules/desktops/tiling/module-config/scripts/niri-shortcuts-menu.sh"
    ["Num_Lock"]="swayosd-client --num-lock toggle"
)

# Function to format shortcut for display
format_shortcut() {
    local key="$1"
    local desc="$2"
    printf "%-25s │ %s" "$key" "$desc"
}

# Create menu items
menu_items=""
for key in "${!shortcuts[@]}"; do
    item=$(format_shortcut "$key" "${shortcuts[$key]}")
    menu_items+="$item\n"
done

# Show fuzzel menu and get selection
selected=$(echo -e "$menu_items" | fuzzel --dmenu --prompt="Keyboard Shortcuts:" --lines=20 --width=80)

# Extract the key combination from the selected line
if [[ -n "$selected" ]]; then
    key=$(echo "$selected" | cut -d'│' -f1 | xargs)
    
    # Check if we have an action for this key
    if [[ -n "${actions[$key]}" ]]; then
        # Execute the action
        eval "${actions[$key]}" &
        
        # Show notification
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "Shortcut Executed" "$key: ${shortcuts[$key]}" --icon=input-keyboard
        fi
    else
        # Fallback: show help message
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "Keyboard Shortcut" "$key: ${shortcuts[$key]}" --icon=input-keyboard
        fi
    fi
fi