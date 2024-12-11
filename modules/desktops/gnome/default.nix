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
      gnomeExtensions.wintile-beyond
      gnomeExtensions.gsconnect
      gnomeExtensions.window-calls
      gnomeExtensions.quick-settings-audio-panel
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.caffeine
      pulseaudio # pactl needed for gnomeExtensions.quick-settings-audio-panel
      gnome-tweaks
    ];

    environment.gnome.excludePackages = with pkgs; [
      # for packages that are pkgs.*
      gnome-tour
      gnome-connections
      cheese # photo booth
      gedit # text editor
      yelp # help viewer
      file-roller # archive manager
      gnome-photos
      gnome-system-monitor
      gnome-maps
      gnome-music
      gnome-weather
      epiphany
    ];

    # environment.gnome.excludePackages = (with pkgs; [
    #   # for packages that are pkgs.*
    #   gnome-tour
    #   gnome-connections
    #   cheese # photo booth
    #   gedit # text editor
    #   yelp # help viewer
    #   file-roller # archive manager
    #   gnome-photos
    #   gnome-system-monitor
    #   gnome-maps
    #   gnome-music
    #   gnome-weather
    #   epiphany
    # ]) ++ (with pkgs.gnomeExtensions; [
    #   # for packages that are pkgs.gnomeExtensions.*
    #   applications-menu
    #   auto-move-windows
    #   gtk4-desktop-icons-ng-ding
    #   launch-new-instance
    #   light-style
    #   native-window-placement
    #   next-up
    #   places-status-indicator
    #   removable-drive-menu
    #   screenshot-window-sizer
    #   window-list
    #   windownavigator
    #   workspace-indicator
    #   hide-top-bar
    # ]);

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
      xdg.enable = true;
    };

    desktops.gnome = { keybindings.enable = true; };

    ##### Home Manager Config options #####
    home-manager.users."${user-settings.user.username}" = {

      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {

        # "org/gnome/mutter" = {
        #   center-new-windows = true;
        #   edge-tiling = false; # for pop-shell
        # };

        "org/gnome/shell" = {
          # Enabled extensions
          enabled-extensions = [
            "wintile-beyond@GrylledCheez.xyz"
            "caffeine@patapon.info"
            "quick-settings-audio-panel@rayzeq.github.io"
            "bluetooth-quick-connect@bjarosze.gmail.com"
          ];

          # Disabled extensions
          disabled-extensions = [
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
            "gsconnect@andyholmes.github.io"
            "window-calls@domandoman.xyz"

          ];
        };

        # Used for desired alt-tab behavior
        "org/gnome/shell/app-switcher" = { current-workspace-only = false; };
        "org/gnome/shell/window-switcher" = { current-workspace-only = false; };

        "org/gnome/shell/extensions/wintile-beyond" = {
          cols = 4;
          rows = 2;
          gap = 0;
          non-ultra-cols = 4;
          non-ultra-rows = 2;
          ultrawide-only = true;
          use-maximize = false;
          use-minimize = false;
        };
        "org/gnome/shell/extensions/bluetooth-quick-connect" = {
          bluetooth-auto-power-on = true;
          refresh-button-on = true;
          show-battery-value-on = true;
        };

        "org/gnome/shell/extensions/caffeine" = {
          indicator-position-max = 2;
          nightlight-control = "always";
          screen-blank = "always";
        };
        "org/gnome/shell/extensions/quick-settings-audio-panel" = {
          always-show-input-slider = true;
          media-control = "move";
          merge-panel = true;
        };

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

          # Fonts
          font-hinting = "full";
          font-antialiasing = "rgba";

          font-name = "Work Sans 12";
          document-font-name = "Work Sans 12";
          monospace-font-name = "Source Code Pro 10";

          # Default Fonts
          # font-name = "Cantarell 11";
          # document-font-name = "Cantarell 11";
          # monospace-font-name = "Source Code Pro 10";

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
