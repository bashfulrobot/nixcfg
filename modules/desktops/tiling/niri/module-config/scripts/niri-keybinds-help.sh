#!/usr/bin/env bash

# Niri Keyboard Shortcuts Help
# Displays all available keyboard shortcuts in a formatted overlay

SHORTCUTS=$(cat << 'EOF'
🌟 NIRI KEYBOARD SHORTCUTS 🌟

━━━ APPLICATION LAUNCHERS ━━━
Super + Space       Launch fuzzel (app launcher)
Super + Return      Launch ghostty (terminal)
Super + T           Launch ghostty (terminal)
Super + E           Launch bemoji (emoji picker)
Super + Z           Launch nautilus (file manager)
Super + N           Toggle swaync (notifications)
Super + \           1password quick access
Super + Shift + Space   Launch Alpaca AI chat

━━━ WINDOW MANAGEMENT ━━━
Super + Q           Close window
Super + Shift + Q   Quit niri
Super + F           Fullscreen window
Super + W           Toggle window floating
Ctrl + Shift + Space    Toggle window floating (alt)

━━━ FOCUS MOVEMENT ━━━
Super + ↑/↓         Focus window up/down
Super + ←/→         Focus column left/right
Super + K/J         Focus window up/down (vim)
Super + H/L         Focus column left/right (vim)
Super + Tab         Focus next window
Super + Shift + Tab Focus previous window
Ctrl + ↓           Toggle overview

━━━ WINDOW MOVEMENT ━━━
Super + Shift + ←/→ Move column left/right
Super + Shift + H/L Move column left/right (vim)
Super + ,           Consume window into column
Super + .           Expel window from column

━━━ COLUMN/WINDOW SIZING ━━━
Super + R           Switch preset column width
Super + Shift + R   Switch preset window height
Super + O           Reset column to 50% width

━━━ WORKSPACE MANAGEMENT ━━━
Super + 1-9         Focus workspace 1-9
Super + Shift + 1-9 Move column to workspace 1-9
Super + Page ↑/↓    Focus workspace up/down
Super + Shift + Page ↑/↓    Move column to workspace up/down

━━━ MONITOR MANAGEMENT ━━━
Super + Ctrl + ↑/↓/←/→   Move column to monitor in direction

━━━ SYSTEM CONTROLS ━━━
Super + Alt + L     Lock screen
Super + Shift + L   Power off monitors

━━━ UTILITIES ━━━
Super + C           Clipboard manager (cliphist)
Super + P           Color picker (hyprpicker)

━━━ SCREENSHOTS ━━━
Print               Screenshot window
Super + Print       Screenshot screen
Super + Shift + S   Screenshot area (select)
Super + Shift + Print   Screenshot screen (alt)

━━━ MEDIA CONTROLS ━━━
XF86AudioPlay/Pause     Play/pause with OSD
XF86AudioNext          Next track with OSD
XF86AudioPrev          Previous track with OSD
XF86AudioMute          Toggle audio mute with OSD
XF86AudioMicMute       Toggle microphone mute with OSD
XF86AudioRaiseVolume   Raise volume with OSD
XF86AudioLowerVolume   Lower volume with OSD

━━━ BRIGHTNESS ━━━
XF86MonBrightnessUp    Increase brightness
XF86MonBrightnessDown  Decrease brightness

━━━ HELP ━━━
Super + ?           Show this help (you are here!)

━━━ SUPPORTING PROGRAMS ━━━
• fuzzel - Application launcher & dmenu
• ghostty - Terminal emulator  
• bemoji - Emoji picker
• nautilus - File manager
• swaync - Notification center
• cliphist - Clipboard history
• hyprpicker - Color picker
• hyprlock - Screen locker
• waybar - Status bar
• swayosd - On-screen display
• playerctl - Media control
• brightnessctl - Brightness control
• blueman-applet - Bluetooth manager

━━━ ENHANCED FEATURES ━━━
• Smart window rules for PiP & KDE apps
• Adaptive input acceleration profiles
• Per-window keyboard layout tracking
• Organized Screenshots folder
• Suspend on lid close (not poweroff)

Press Escape to close
EOF
)

# Display the shortcuts using fuzzel as a non-interactive display
echo "$SHORTCUTS" | fuzzel --dmenu \
    --prompt="Niri Shortcuts:" \
    --no-fuzzy \
    --no-icons \
    --width=80 \
    --lines=50 \
    --font="JetBrains Mono:size=10" \
    --background-color="1e1e2eff" \
    --text-color="cdd6f4ff" \
    --match-color="f38ba8ff" \
    --selection-color="313244ff" \
    --selection-text-color="f9e2afff" \
    --border-width=2 \
    --border-color="89b4faff" \
    --line-height=18