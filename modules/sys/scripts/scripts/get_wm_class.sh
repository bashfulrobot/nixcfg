#!/run/current-system/sw/bin/env bash

# Check if hyprctl is installed
if command -v hyprctl &> /dev/null
then
    # Execute the original commands
    hyprctl clients | grep 'class:' | awk '{print $2}' | fzf | wl-copy --trim-newline
else
    # Fallback to gdbus if hyprctl is not found
    gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.List | grep -Po '"wm_class_instance":"\K[^"]*' | fzf | wl-copy --trim-newline
fi

exit 0