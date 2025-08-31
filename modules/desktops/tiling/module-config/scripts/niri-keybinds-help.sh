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

━━━ SCREENCASTING ━━━
Super + Shift + W   Toggle windowed fullscreen
Super + Shift + C   Set window as cast target
Super + Shift + M   Set monitor as cast target
Super + Shift + Esc Clear cast target

━━━ MEDIA CONTROLS ━━━
XF86AudioPlay/Pause     Play/pause with OSD
XF86AudioNext          Next track with OSD
XF86AudioPrev          Previous track with OSD
XF86AudioMute          Toggle audio mute with OSD
XF86AudioMicMute       Toggle microphone mute with OSD
XF86AudioRaiseVolume   Raise volume with OSD
XF86AudioLowerVolume   Lower volume with OSD

━━━ BRIGHTNESS ━━━
XF86MonBrightnessUp    Increase brightness with OSD
XF86MonBrightnessDown  Decrease brightness with OSD

━━━ LOCK STATUS ━━━
Caps_Lock              Show Caps Lock status
Num_Lock               Show Num Lock status

━━━ SYSTEM MONITORING ━━━
Super + F1             Show battery level
Super + F2             Show memory usage
Super + F3             Show CPU temperature
Super + F4             Show disk usage
Super + Shift + F1     Show microphone volume
Super + Shift + F2     Show WiFi signal strength

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
# Note: Colors are handled automatically by Stylix theming
echo "$SHORTCUTS" | fuzzel --dmenu \
    --prompt="Niri Shortcuts:" \
    --no-fuzzy \
    --no-icons \
    --width=80 \
    --lines=50 \
    --font="JetBrainsMono Nerd Font Mono:size=12" \
    --border-width=2 \
    --line-height=18