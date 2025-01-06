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
      unstable.gnomeExtensions.tiling-shell
      gnomeExtensions.gsconnect
      gnomeExtensions.vscode-search-provider
      gnomeExtensions.vscode-workspaces-gnome
      gnomeExtensions.window-calls
      gnomeExtensions.quick-settings-audio-panel
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.caffeine
      gnomeExtensions.media-controls
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
      gnome-photos
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

      # https://discourse.nixos.org/t/cant-get-gnupg-to-work-no-pinentry/15373/13?u=brnix
      home.file.".gnupg/gpg-agent.conf".text = ''
        pinentry-program /run/current-system/sw/bin/pinentry
      '';

      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {

        # "org/gnome/mutter" = {
        #   center-new-windows = true;
        #   edge-tiling = false; # for pop-shell
        # };

        "org/gnome/shell" = {
          # Enabled extensions
          enabled-extensions = [
            "tilingshell@ferrarodomenico.com"
            "caffeine@patapon.info"
            "quick-settings-audio-panel@rayzeq.github.io"
            "bluetooth-quick-connect@bjarosze.gmail.com"
            "mediacontrols@cliffniff.github.com"
            "vscode-search-provider@mrmarble.github.com"
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

        "org/gnome/shell/extensions/mediacontrols" = {
          extension-position = "Right";
          label-width = mkUint32 0;
          mediacontrols-show-popup-menu = [ "<Shift><Control><Alt>m" ];
        };

        "org/gnome/shell/extensions/tilingshell" = {
          enable-blur-selected-tilepreview = true;
          enable-blur-snap-assistant = true;
          last-version-name-installed = "14";
          layouts-json = ''
            [{"id":"Layout 1","tiles":[{"x":0,"y":0,"width":0.22,"height":0.5,"groups":[1,2]},{"x":0,"y":0.5,"width":0.22,"height":0.5,"groups":[1,2]},{"x":0.22,"y":0,"width":0.56,"height":1,"groups":[2,3]},{"x":0.78,"y":0,"width":0.22,"height":0.5,"groups":[3,4]},{"x":0.78,"y":0.5,"width":0.22,"height":0.5,"groups":[3,4]}]},{"id":"Layout 2","tiles":[{"x":0,"y":0,"width":0.22,"height":1,"groups":[1]},{"x":0.22,"y":0,"width":0.56,"height":1,"groups":[1,2]},{"x":0.78,"y":0,"width":0.22,"height":1,"groups":[2]}]},{"id":"Layout 3","tiles":[{"x":0,"y":0,"width":0.33,"height":1,"groups":[1]},{"x":0.33,"y":0,"width":0.67,"height":1,"groups":[1]}]},{"id":"Layout 4","tiles":[{"x":0,"y":0,"width":0.67,"height":1,"groups":[1]},{"x":0.67,"y":0,"width":0.33,"height":1,"groups":[1]}]},{"id":"3722439","tiles":[{"x":0,"y":0,"width":0.35358796296296297,"height":0.49234449760765553,"groups":[1,2]},{"x":0.35358796296296297,"y":0,"width":0.6464120370370365,"height":1,"groups":[1]},{"x":0,"y":0.49234449760765553,"width":0.35358796296296297,"height":0.5076555023923448,"groups":[2,1]}]}]'';
          overridden-settings = ''
            {"org.gnome.mutter.keybindings":{"toggle-tiled-right":"['<Super>Right']","toggle-tiled-left":"['<Super>Left']"},"org.gnome.desktop.wm.keybindings":{"maximize":"['<Super>Up']","unmaximize":"['<Super>Down', '<Alt>F5']"},"org.gnome.mutter":{"edge-tiling":"false"}}'';
          quarter-tiling-threshold = mkUint32 41;
          show-indicator = false;
          snap-assistant-threshold = 57;
          tiling-system-activation-key = [ "0" ];
          top-edge-maximize = true;
          span-window-right = [ "<Control><Super>Right" ];
          span-window-left = [ "<Control><Super>Left" ];
          span-window-up = [ "<Control><Super>Up" ];
          span-window-down = [ "<Control><Super>Down" ];
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
