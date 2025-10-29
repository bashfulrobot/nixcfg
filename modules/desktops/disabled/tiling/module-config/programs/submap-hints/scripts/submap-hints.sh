#!/usr/bin/env bash
# Submap hints display script

# Use your standard rofi theme
rofi_theme="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/launchers/type-2/style-2.rasi"

case "$1" in
  "resize")
    r_override="listview{lines:4;columns:1;}window{width:400px;}inputbar{enabled:false;}"
    echo -e "Resize Mode\n\nh/l = width\nk/j = height\nESC/Enter = Exit" | rofi -dmenu -p "↔ Resize" -theme "$rofi_theme" -theme-str "$r_override"
    ;;
  "explore")
    r_override="listview{lines:6;columns:1;}window{width:450px;}inputbar{enabled:false;}"
    echo -e "Explore Mode\n\nd = Downloads\no = Documents\nv = dev\ns = Screenshots\nn = nixcfg\nESC/Enter = Exit" | rofi -dmenu -p "󰉋 Explore" -theme "$rofi_theme" -theme-str "$r_override"
    ;;
  "special")
    r_override="listview{lines:5;columns:1;}window{width:400px;}inputbar{enabled:false;}"
    echo -e "Special Workspaces\n\ns = Scratch\nm = Music (Spotify)\np = 1Password\nESC/Enter = Exit" | rofi -dmenu -p " Special" -theme "$rofi_theme" -theme-str "$r_override"
    ;;
  *)
    echo "Usage: submap-hints {resize|explore|special}"
    exit 1
    ;;
esac