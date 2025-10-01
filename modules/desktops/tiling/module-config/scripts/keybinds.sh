#!/usr/bin/env bash

if pidof rofi >/dev/null; then
  pkill rofi
fi

if pidof yad >/dev/null; then
  pkill yad
fi

# get_nix_value() {
#     grep "$1" "$HOME/NixOS/flake.nix" | sed -E 's/.*"([^"]+)".*/\1/'
# }
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
_terminal_FM=$(get_nix_value "terminalFileManager =")

yad \
  --center \
  --title="Hyprland Keybinds" \
  --no-buttons \
  --list \
  --width=745 \
  --height=920 \
  --column=Key: \
  --column=Description: \
  --column=Command: \
  --timeout-indicator=bottom \
  "SUPER Return" "Launch terminal" "$_terminal" \
  "SUPER T" "Launch terminal" "$_terminal" \
  "SUPER E" "Launch file manager" "$_terminal_FM" \
  "SUPER F" "Launch browser" "$_browser" \
  "SUPER SHIFT S" "Launch spotify" "spotify" \
  "CTRL ALT Delete" "Open system monitor" "$_terminal -e 'btop'" \
  "SUPER A" "Launch application menu" "scripts/rofi.sh drun" \
  "SUPER SPACE" "Launch application menu" "scripts/rofi.sh drun" \
  "SUPER F9" "Enable night mode" "hyprsunset --temperature 2500" \
  "SUPER F10" "Disable night mode" "pkill hyprsunset" \
  "SUPER F8" "Toggle autoclicker" "scripts/autoclicker.nix" \
  "SUPER ;" "Split Horizontal (next window right)" "layoutmsg, preselect r" \
  "SUPER '" "Split Vertical (next window below)" "layoutmsg, preselect d" \
  "SUPER CTRL C" "Colour picker" "hyprpicker --autocopy" \
  "SUPER, Left Click" "Move window with mouse" "movewindow" \
  "SUPER, Right Click" "Resize window with mouse" "resizewindow" \
  "SUPER SHIFT →" "Resize window right" "resizeactive 30 0" \
  "SUPER SHIFT ←" "Resize window left" "resizeactive -30 0" \
  "SUPER SHIFT ↑" "Resize window up" "resizeactive 0 -30" \
  "SUPER SHIFT ↓" "Resize window down" "resizeactive 0 30" \
  "SUPER R" "Enter resize mode" "submap resize" \
  "In resize mode: HJKL" "Resize window, ESC/Enter to exit" "hjkl keys" \
  "SUPER O" "Toggle split direction" "togglesplit" \
  "XF86MonBrightnessDown" "Decrease brightness" "brightnessctl set 2%-" \
  "XF86MonBrightnessUp" "Increase brightness" "brightnessctl set +2%" \
  "XF86AudioLowerVolume" "Lower volume" "pamixer -d 2" \
  "XF86AudioRaiseVolume" "Increase volume" "pamixer -i 2%" \
  "XF86AudioMicMute" "Mute microphone" "pamixer --default-source -t" \
  "XF86AudioMute" "Mute audio" "pamixer -t" \
  "XF86AudioPlay" "Play/Pause media" "playerctl play-pause" \
  "XF86AudioNext" "Next media track" "playerctl next" \
  "XF86AudioPrev" "Previous media track" "playerctl previous" \
  "SUPER Delete" "Exit Hyprland session" "exit" \
  "SUPER W" "Toggle floating window" "togglefloating" \
  "SUPER SHIFT G" "Toggle window group" "togglegroup" \
  "ALT Return" "Toggle fullscreen" "fullscreen" \
  "SUPER ALT L" "Lock screen" "hyprlock" \
  "SUPER Backspace" "Power menu" "wlogout -b 4" \
  "CTRL Escape" "Toggle Waybar" "pkill waybar || waybar" \
  "SUPER SHIFT N" "Open notification panel" "swaync-client -t -sw" \
  "SUPER SHIFT Q" "Open notification panel" "swaync-client -t -sw" \
  "SUPER Q" "Close active window" "scripts/dontkillsteam.sh" \
  "ALT F4" "Close active window" "scripts/dontkillsteam.sh" \
  "SUPER Z" "Launch emoji picker" "scripts/rofi.sh emoji" \
  "SUPER ALT K" "Change keyboard layout" "scripts/keyboardswitch.sh" \
  "SUPER ALT B" "Bluetooth manager" "blueman-manager" \
  "SUPER U" "Rebuild system" "$_terminal -e scripts/rebuild.sh" \
  "SUPER G" "Game launcher" "scripts/rofi.sh games" \
  "SUPER ALT G" "Enable game mode" "scripts/gamemode.sh" \
  "SUPER V" "Clipboard manager" "scripts/ClipManager.sh" \
  "SUPER M" "Online music" "scripts/rofimusic.sh" \
  "SUPER P" "Screenshot (select area)" "scripts/screenshot.sh s" \
  "SUPER CTRL P" "Screenshot (frozen screen)" "scripts/screenshot.sh sf" \
  "SUPER Print" "Screenshot (current monitor)" "scripts/screenshot.sh m" \
  "SUPER ALT P" "Screenshot (all monitors)" "scripts/screenshot.sh p" \
  "SUPER SHIFT ←" "Move window left" "movewindow l" \
  "SUPER SHIFT →" "Move window right" "movewindow r" \
  "SUPER SHIFT ↑" "Move window up" "movewindow u" \
  "SUPER SHIFT ↓" "Move window down" "movewindow d" \
  "SUPER SHIFT H" "Move window left (HJKL)" "movewindow l" \
  "SUPER SHIFT L" "Move window right (HJKL)" "movewindow r" \
  "SUPER SHIFT K" "Move window up (HJKL)" "movewindow u" \
  "SUPER SHIFT J" "Move window down (HJKL)" "movewindow d" \
  "SUPER SHIFT CTRL H" "Swap window left (HJKL)" "swapwindow l" \
  "SUPER SHIFT CTRL L" "Swap window right (HJKL)" "swapwindow r" \
  "SUPER SHIFT CTRL K" "Swap window up (HJKL)" "swapwindow u" \
  "SUPER SHIFT CTRL J" "Swap window down (HJKL)" "swapwindow d" \
  "SUPER CTRL S" "Move to scratchpad" "movetoworkspacesilent special" \
  "SUPER S" "Toggle scratchpad workspace" "togglespecialworkspace" \
  "SUPER Tab" "Cycle next window" "cyclenext" \
  "SUPER Tab" "Bring active window to top" "bringactivetotop" \
  "SUPER CTRL →" "Switch to next workspace" "workspace r+1" \
  "SUPER CTRL ←" "Switch to previous workspace" "workspace r-1" \
  "SUPER CTRL ↓" "Go to first empty workspace" "workspace empty" \
  "SUPER ←" "Move focus left" "movefocus l" \
  "SUPER →" "Move focus right" "movefocus r" \
  "SUPER ↑" "Move focus up" "movefocus u" \
  "SUPER ↓" "Move focus down" "movefocus d" \
  "SUPER H" "Move focus left (HJKL)" "movefocus l" \
  "SUPER L" "Move focus right (HJKL)" "movefocus r" \
  "SUPER K" "Move focus up (HJKL)" "movefocus u" \
  "SUPER J" "Move focus down (HJKL)" "movefocus d" \
  "ALT Tab" "Move focus down" "movefocus d" \
  "SUPER 1-0" "Switch to workspace 1-10" "workspace 1-10" \
  "SUPER SHIFT 1-0" "Move to workspace 1-10" "movetoworkspace 1-10" \
  "SUPER SHIFT 1-0" "Silently move to workspace 1-10" "movetoworkspacesilent 1-10" \
