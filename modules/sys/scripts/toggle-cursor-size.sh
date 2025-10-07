#!/run/current-system/sw/bin/env bash

# Get the current cursor size
current_size=$(dconf read /org/gnome/desktop/interface/cursor-size)

# Toggle the cursor size
if [ "$current_size" -eq 120 ]; then
  dconf write /org/gnome/desktop/interface/cursor-size 25
  dconf write /org/gnome/desktop/interface/cursor-theme "'Adwaita'"
elif [ "$current_size" -eq 25 ]; then
  dconf write /org/gnome/desktop/interface/cursor-size 120
  dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Modern-Amber'"
else
  dconf write /org/gnome/desktop/interface/cursor-size 120
  dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Modern-Amber'"
fi

exit 0