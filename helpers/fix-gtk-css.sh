#!/usr/bin/env bash
# Fix GTK CSS file conflicts by removing regular files that interfere with home-manager symlinks

echo "Removing GTK CSS files that conflict with home-manager..."

# Remove the conflicting files if they exist and are regular files (not symlinks)
if [[ -f ~/.config/gtk-3.0/gtk.css && ! -L ~/.config/gtk-3.0/gtk.css ]]; then
    echo "Removing ~/.config/gtk-3.0/gtk.css"
    rm ~/.config/gtk-3.0/gtk.css
fi

if [[ -f ~/.config/gtk-4.0/gtk.css && ! -L ~/.config/gtk-4.0/gtk.css ]]; then
    echo "Removing ~/.config/gtk-4.0/gtk.css"
    rm ~/.config/gtk-4.0/gtk.css
fi

echo "GTK CSS conflicts fixed"