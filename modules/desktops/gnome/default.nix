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
      };

    };

    environment.systemPackages = with pkgs; [
      pinentry-all # gpg passphrase prompting
      gnome-tweaks
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
      epiphany
    ];

    system.activationScripts.script.text = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      cp ${user-settings.user.home}/dev/nix/nixcfg/modules/desktops/gnome/.face /var/lib/AccountsService/icons/${user-settings.user.username}
      echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${user-settings.user.username}\n" > /var/lib/AccountsService/users/${user-settings.user.username}

      chown root:root /var/lib/AccountsService/users/${user-settings.user.username}
      chmod 0600 /var/lib/AccountsService/users/${user-settings.user.username}

      chown root:root /var/lib/AccountsService/icons/${user-settings.user.username}
      chmod 0444 /var/lib/AccountsService/icons/${user-settings.user.username}
    '';

    sys = {
      dconf.enable = true;
      catppuccin-theme.enable = true;
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
          accent-color = "yellow";

          # Fonts
          font-hinting = "full";
          font-antialiasing = "rgba";

          font-name = "Work Sans 12";
          document-font-name = "Work Sans 12";
          monospace-font-name = "Source Code Pro 10";
        };
        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri =
            "file:///run/current-system/sw/share/backgrounds/gnome/symbolic-soup-l.jxl";
          picture-uri-dark =
            "file:///run/current-system/sw/share/backgrounds/gnome/symbolic-soup-d.jxl";
          primary-color = "#B9B5AE";
          secondary-color = "#000000";
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
