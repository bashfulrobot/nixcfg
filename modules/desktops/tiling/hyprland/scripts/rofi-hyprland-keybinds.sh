#!/usr/bin/env bash

# Rofi-based keybinds cheatsheet for NixOS Hyprland setup
# Adapted from: https://github.com/jason9075/rofi-hyprland-keybinds-cheatsheet

# Since your Hyprland config is in NixOS format, we'll create a static list
# that matches your actual keybindings from the Nix configuration

get_nix_value() {
    # Get user home from settings.json, fallback to $HOME
    local user_home
    if command -v jq >/dev/null 2>&1; then
        user_home=$(jq -r '.user.home // empty' "$HOME/dev/nix/nixcfg/settings/settings.json" 2>/dev/null || echo "$HOME")
    else
        user_home="$HOME"
    fi
    local nixcfg_dir="${user_home}/dev/nix/nixcfg"

    awk '
    /settings = {/ {inside_settings=1; next}
    inside_settings && /}/ {inside_settings=0}
    inside_settings && $0 ~ key {print gensub(/.*"([^"]+)".*/, "\\1", "g", $0)}
    ' key="$1" "$nixcfg_dir/flake.nix"
}

_browser=$(get_nix_value "browser =")
_terminal=$(get_nix_value "terminal =")

# Create keybind list in rofi markup format
BINDINGS=(
    "<b>SUPER + Return</b>  <i>Launch terminal</i>"
    "<b>SUPER + T</b>  <i>Launch terminal</i>"
    "<b>SUPER + E</b>  <i>Explore mode (file manager)</i>"
    "<b>SUPER + B</b>  <i>Launch browser</i>"
    "<b>SUPER + C</b>  <i>Launch code editor</i>"
    "<b>SUPER + SHIFT + S</b>  <i>Launch Spotify</i>"
    "<b>SUPER + SHIFT + Y</b>  <i>Launch YouTube Music</i>"
    "<b>CTRL + ALT + Delete</b>  <i>Open system monitor</i>"
    "<b>SUPER + A</b>  <i>Launch application menu</i>"
    "<b>SUPER + SPACE</b>  <i>Launch application menu</i>"
    "<b>SUPER + F9</b>  <i>Enable night mode</i>"
    "<b>SUPER + F10</b>  <i>Disable night mode</i>"
    "<b>SUPER + F8</b>  <i>Toggle autoclicker</i>"
    "<b>SUPER + ;</b>  <i>Split horizontal (next window right)</i>"
    "<b>SUPER + '</b>  <i>Split vertical (next window below)</i>"
    "<b>SUPER + CTRL + C</b>  <i>Color picker</i>"
    "<b>SUPER + Left Click</b>  <i>Move window with mouse</i>"
    "<b>SUPER + Right Click</b>  <i>Resize window with mouse</i>"
    "<b>SUPER + SHIFT + →</b>  <i>Resize window right</i>"
    "<b>SUPER + SHIFT + ←</b>  <i>Resize window left</i>"
    "<b>SUPER + SHIFT + ↑</b>  <i>Resize window up</i>"
    "<b>SUPER + SHIFT + ↓</b>  <i>Resize window down</i>"
    "<b>SUPER + R</b>  <i>Enter resize mode</i>"
    "<b>SUPER + O</b>  <i>Toggle split direction</i>"
    "<b>SUPER + Delete</b>  <i>Exit Hyprland session</i>"
    "<b>SUPER + W</b>  <i>Toggle floating window</i>"
    "<b>SUPER + SHIFT + G</b>  <i>Toggle window group</i>"
    "<b>ALT + Return</b>  <i>Toggle fullscreen</i>"
    "<b>SUPER + ALT + L</b>  <i>Lock screen</i>"
    "<b>SUPER + Backspace</b>  <i>Power menu</i>"
    "<b>CTRL + Escape</b>  <i>Toggle Waybar</i>"
    "<b>SUPER + SHIFT + N</b>  <i>Open notification panel</i>"
    "<b>SUPER + Q</b>  <i>Close active window</i>"
    "<b>ALT + F4</b>  <i>Close active window</i>"
    "<b>SUPER + Z</b>  <i>Launch emoji picker</i>"
    "<b>SUPER + ALT + K</b>  <i>Change keyboard layout</i>"
    "<b>SUPER + ALT + B</b>  <i>Bluetooth manager</i>"
    "<b>SUPER + U</b>  <i>Rebuild system</i>"
    "<b>SUPER + G</b>  <i>Game launcher</i>"
    "<b>SUPER + ALT + G</b>  <i>Enable game mode</i>"
    "<b>SUPER + V</b>  <i>Clipboard manager</i>"
    "<b>SUPER + M</b>  <i>Online music</i>"
    "<b>SUPER + P</b>  <i>Screenshot (select area)</i>"
    "<b>SUPER + CTRL + P</b>  <i>Screenshot (frozen screen)</i>"
    "<b>SUPER + Print</b>  <i>Screenshot (current monitor)</i>"
    "<b>SUPER + ALT + P</b>  <i>Screenshot (all monitors)</i>"
    "<b>SUPER + S</b>  <i>Special workspaces menu</i>"
    "<b>SUPER + CTRL + S</b>  <i>Move window to special workspaces menu</i>"
    "<b>SUPER + SHIFT + S</b>  <i>Move window to scratchpad</i>"
    "<b>SUPER + Tab</b>  <i>Cycle next window</i>"
    "<b>SUPER + CTRL + →</b>  <i>Switch to next workspace</i>"
    "<b>SUPER + CTRL + ←</b>  <i>Switch to previous workspace</i>"
    "<b>SUPER + CTRL + ↓</b>  <i>Go to first empty workspace</i>"
    "<b>SUPER + ← → ↑ ↓</b>  <i>Move focus (arrow keys)</i>"
    "<b>SUPER + H J K L</b>  <i>Move focus (vim keys)</i>"
    "<b>ALT + Tab</b>  <i>Move focus down</i>"
    "<b>SUPER + 1-0</b>  <i>Switch to workspace 1-10 (works from special workspaces)</i>"
    "<b>SUPER + SHIFT + 1-0</b>  <i>Move window to workspace 1-10 (works from anywhere)</i>"
    "<b>SUPER + CTRL + 1-0</b>  <i>Silently move to workspace 1-10</i>"
    ""
    "<span color='gray'><i>Special Workspace Submap (SUPER + S):</i></span>"
    "<b>S</b>  <i>Toggle scratchpad</i>"
    "<b>M</b>  <i>Toggle music (Spotify)</i>"
    "<b>P</b>  <i>Toggle password (1Password)</i>"
    ""
    "<span color='gray'><i>Move to Special Submap (SUPER + CTRL + S):</i></span>"
    "<b>S</b>  <i>Move window to scratchpad</i>"
    "<b>M</b>  <i>Move window to music workspace</i>"
    "<b>P</b>  <i>Move window to 1Password workspace</i>"
    ""
    "<span color='gray'><i>Explore Mode Submap (SUPER + E):</i></span>"
    "<b>D</b>  <i>Downloads folder</i>"
    "<b>O</b>  <i>Documents folder</i>"
    "<b>V</b>  <i>Dev folder</i>"
    "<b>S</b>  <i>Screenshots folder</i>"
    "<b>N</b>  <i>NixCfg folder</i>"
    ""
    "<span color='gray'><i>Resize Mode Submap (SUPER + R):</i></span>"
    "<b>H J K L</b>  <i>Resize window, ESC/Enter to exit</i>"
    ""
    "<span color='gray'><i>Media Keys:</i></span>"
    "<b>XF86MonBrightnessDown/Up</b>  <i>Brightness control</i>"
    "<b>XF86AudioLowerVolume/RaiseVolume</b>  <i>Volume control</i>"
    "<b>XF86AudioMicMute</b>  <i>Mute microphone</i>"
    "<b>XF86AudioMute</b>  <i>Mute audio</i>"
    "<b>XF86AudioPlay</b>  <i>Play/Pause media</i>"
    "<b>XF86AudioNext/Prev</b>  <i>Next/Previous track</i>"
)

# Show rofi menu with keybinds
CHOICE=$(printf '%s\n' "${BINDINGS[@]}" | rofi -dmenu -i -markup-rows -p " Hyprland Keybinds" -theme-str 'window {width: 60%;} listview {lines: 20;}')

# Since this is display-only, we don't execute commands
# The user can see the keybinds and use them directly