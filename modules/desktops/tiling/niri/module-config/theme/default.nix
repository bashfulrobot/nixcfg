{ lib, config, user-settings, pkgs, ... }:
{
  sys = {
    wallpapers.enable = true;
    stylix-theme.enable = true;
  };

  # Puts a custom icon for the user in the login screen
  system.activationScripts.script.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp ${user-settings.user.home}/dev/nix/nixcfg/modules/desktops/tiling/niri/module-config/assets/.face /var/lib/AccountsService/icons/${user-settings.user.username}
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${user-settings.user.username}\n" > /var/lib/AccountsService/users/${user-settings.user.username}

    chown root:root /var/lib/AccountsService/users/${user-settings.user.username}
    chmod 0600 /var/lib/AccountsService/users/${user-settings.user.username}

    chown root:root /var/lib/AccountsService/icons/${user-settings.user.username}
    chmod 0444 /var/lib/AccountsService/icons/${user-settings.user.username}

    # Update icon caches for proper notification icons in lock screen
    if [ -x "${pkgs.gtk3.out}/bin/gtk-update-icon-cache" ]; then
      for theme_dir in /run/current-system/sw/share/icons/*; do
        if [ -d "$theme_dir" ]; then
          echo "Updating icon cache for $(basename "$theme_dir")"
          ${pkgs.gtk3.out}/bin/gtk-update-icon-cache -f -t "$theme_dir" 2>/dev/null || true
        fi
      done
      # Also update user-specific icon cache
      if [ -d "${user-settings.user.home}/.local/share/icons" ]; then
        for user_theme_dir in ${user-settings.user.home}/.local/share/icons/*; do
          if [ -d "$user_theme_dir" ]; then
            echo "Updating user icon cache for $(basename "$user_theme_dir")"
            ${pkgs.gtk3.out}/bin/gtk-update-icon-cache -f -t "$user_theme_dir" 2>/dev/null || true
          fi
        done
      fi
    fi
  '';

}
