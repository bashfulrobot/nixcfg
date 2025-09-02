{ user-settings, pkgs, config, lib, inputs, ... }:
let cfg = config.desktops.gnome;
in {
  options = {
    desktops.gnome.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Gnome Desktop";
    };
  };

  config = lib.mkIf cfg.enable {

    services = {
      # As per: https://discourse.nixos.org/t/cant-get-gnupg-to-work-no-pinentry/15373/4?u=brnix
      # dbus.packages = [ pkgs.gcr ];
      # https://discourse.nixos.org/t/cant-get-gnupg-to-work-no-pinentry/15373/2?u=brnix
      # pcscd.enable = true;
      xserver = {
        # Enable the X11 windowing system.
        enable = true;
        # Enable the GNOME Desktop Environment.
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
        # Configure keymap in X11
        xkb = {
          layout = "us";
          variant = "";
        };
        excludePackages = [ pkgs.xterm ];
      };

    };

    environment.systemPackages = with pkgs; [
      pinentry-all # gpg passphrase prompting
      gnome-tweaks
      nautilus-open-any-terminal # open terminal(s) in nautilus
      file-roller # GNOME archive manager - core desktop component
      gnome-screenshot # Re-adding since flameshot doesn't work in Wayland
      fzf # Terminal-based fuzzy finder for theme selection
      # Icon theme support for notifications
      hicolor-icon-theme
      shared-mime-info
      desktop-file-utils
      gtk3.out # for gtk-update-icon-cache
    ];

    environment.gnome.excludePackages = with pkgs; [
      # for packages that are pkgs.*
      gnome-tour
      gnome-connections
      cheese # photo booth
      gedit # text editor
      yelp # help viewer
      gnome-photos
      gnome-maps
      gnome-music
      gnome-weather
      gnome-console
    ];

    system.activationScripts.script.text = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      cp ${user-settings.user.home}/dev/nix/nixcfg/modules/desktops/gnome/.face /var/lib/AccountsService/icons/${user-settings.user.username}
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

    sys = {
      dconf.enable = true;
      stylix-theme.enable = true;
      xdg.enable = true;
    };

    desktops.gnome = {
      keybindings.enable = true;
      extensions.enable = true;
    };


    ##### Home Manager Config options #####
    home-manager.users."${user-settings.user.username}" = {

      # https://discourse.nixos.org/t/cant-get-gnupg-to-work-no-pinentry/15373/13?u=brnix
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program /run/current-system/sw/bin/pinentry
      '';

      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {

        # Used for desired alt-tab behavior
        "org/gnome/shell/app-switcher" = { current-workspace-only = false; };
        "org/gnome/shell/window-switcher" = { current-workspace-only = false; };

        "org/gnome/desktop/peripherals/touchpad" = {
          two-finger-scrolling-enabled = true;
          edge-scrolling-enabled = false;
          tap-to-click = true;
          natural-scroll = false;
          disable-while-typing = true;
          click-method = "fingers";
        };

        "org/gnome/desktop/peripherals/mouse" = { natural-scroll = false; };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
        };

        "org/gnome/Console" = {
          theme = "auto";
          font-scale = 1.5;
          custom-font = "JetBrainsMonoNL Nerd Font Mono 14";
          scrollback-lines = mkInt64 100000;
        };

        "org/gnome/desktop/sound" = { allow-volume-above-100-percent = true; };

        # #### Visual

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = "slate";
          # fonts managed by stylix

          # Font rendering settings
          font-hinting = "full";
          font-antialiasing = "rgba";
        };
        "org/gnome/desktop/background" = {
          color-shading-type = lib.mkDefault "solid";
          picture-options = lib.mkDefault "zoom";
          picture-uri = lib.mkDefault
            "file:///run/current-system/sw/share/backgrounds/gnome/symbolic-soup-l.jxl";
          picture-uri-dark = lib.mkDefault
            "file:///run/current-system/sw/share/backgrounds/gnome/symbolic-soup-d.jxl";
          primary-color = lib.mkDefault "#B9B5AE";
          secondary-color = lib.mkDefault "#000000";
        };
        "org/gnome/desktop/screensaver" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri =
            "file:///run/current-system/sw/share/backgrounds/gnome/symbolic-soup-l.jxl";
          primary-color = "#B9B5AE";
          secondary-color = "#000000";
        };

      };

    };
  };
}
