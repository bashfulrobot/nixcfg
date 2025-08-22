{ user-settings, lib, config, pkgs, inputs, ... }:
let cfg = config.desktops.gnome.keybindings;
in {

  options = {
    desktops.gnome.keybindings.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable desktops.gnome.keybindings.";
    };
  };

  config = lib.mkIf cfg.enable {

    # environment.systemPackages = with pkgs; [
    #  ];

    desktops.gnome = { keybindings.display-custom-keybindings.enable = true; };

    home-manager.users."${user-settings.user.username}" = {
      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {
        #  Set Media Keys
        "org/gnome/settings-daemon/plugins/media-keys" = {
          play = [ "AudioPlay" ];
          volume-down = [ "AudioLowerVolume" ];
          volume-mute = [ "AudioMute" ];
          volume-up = [ "AudioRaisdonkey-konglume" ];
        };

        # "org/gnome/mutter/keybindings" = {
        #   toggle-tiled-left = [ ]; # for pop-shell
        #   toggle-tiled-right = [ ]; # for pop-shell
        # };

        "org/gnome/shell/keybindings" = {
          show-screenshot-ui = [ "<Control><Alt>p" ];
          switch-to-application-1 = [ ];
          switch-to-application-2 = [ ];
          switch-to-application-3 = [ ];
          switch-to-application-4 = [ ];
          switch-to-application-5 = [ ];
          switch-to-application-6 = [ ];
          switch-to-application-7 = [ ];
          switch-to-application-8 = [ ];
          switch-to-application-9 = [ ];
        };

        "org/gnome/desktop/wm/keybindings" = {
          # Alt-tab behavior
          switch-applications = [ ];
          switch-applications-backward = [ ];
          switch-windows = [ "<Alt>Tab" ];
          switch-windows-backward = [ "<Shift><Alt>Tab" ];

          close = [ "<Super>q" ];
          toggle-fullscreen = [ "<Super>f" ];
          # maximize = [ "<Super>m" ];
          maximize = [ ];
          unmaximize = [ ];
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          switch-to-workspace-6 = [ "<Super>6" ];
          switch-to-workspace-7 = [ "<Super>7" ];
          switch-to-workspace-8 = [ "<Super>8" ];
          switch-to-workspace-9 = [ "<Super>9" ];

          move-to-workspace-1 = [ "<Shift><Super>1" ];
          move-to-workspace-2 = [ "<Shift><Super>2" ];
          move-to-workspace-3 = [ "<Shift><Super>3" ];
          move-to-workspace-4 = [ "<Shift><Super>4" ];
          move-to-workspace-5 = [ "<Shift><Super>5" ];
          move-to-workspace-6 = [ "<Shift><Super>6" ];
          move-to-workspace-7 = [ "<Shift><Super>7" ];
          move-to-workspace-8 = [ "<Shift><Super>8" ];
          move-to-workspace-9 = [ "<Shift><Super>9" ];
          toggle-message-tray = [ "<Shift><Super>n" ];
          panel-run-dialog = [ ];
          switch-input-source = [ ];
          switch-input-source-backward = [ ];
        };

        #  Custom Keybindings
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom14/"
          ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
          {
            binding = "<Super>t";
            # command = "kgx";
            # command = "alacritty";
            # command = "ghostty";
            # command = "foot";
            # command = "blackbox";
            command = "blackbox";
            name = "Default Terminal";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
          {
            binding = "<Control><Alt>a";
            command =
              "/etc/profiles/per-user/dustin/bin/screenshot-annotate.sh";
            name = "Annotate Screenshot";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" =
          {
            binding = "<Super>b";
            command = "chromium";
            name = "Default Browser";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" =
          {
            binding = "<Super>e";
            command = "code";
            name = "Default Editor";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" =
          {
            binding = "<Control><Alt>o";
            command = "/etc/profiles/per-user/dustin/bin/screenshot-ocr.sh";
            name = "OCR Screenshot";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" =
          {
            binding = "<Control><Shift>x";
            command = "/run/current-system/sw/bin/1password --quick-access";
            name = "1password quick access";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" =
          {
            binding = "<Alt>p";
            command = "/run/current-system/sw/bin/1password --toggle";
            name = "show 1password";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" =
          {
            binding = "<Super>n";
            command = "/etc/profiles/per-user/dustin/bin/nautilus ~/dev";
            name = "open files in ~/dev";
          };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" =
          {
            binding = "<Control><Alt><Super>g";
            command = "gmail-url";
            name = "Transform gmail url to archive url on your clipboard";
          };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" =
          {
            binding = "<Control>space";
            command = "toggle-cursor-size";
            name = "toggle large cursor in presentations";
          };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" =
          {
            binding = "<Super><Shift>A";
            command = "set-audio-in-out";
            name = "Set Audio Devices";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" =
          {
            binding = "<Super><Shift>p";
            command = "flatpak run com.onepassword.OnePassword";
            name = "Open 1password flatpak as a workaround";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12" =
          {
            binding = "<Control><Alt><Shift>s";
            command = "ncspot-save-playing";
            name =
              "Save currently playing song in NCSPOT to library in Spotify";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13" =
          {
            # ctrl-shift-?
            binding = "<Control><Shift>slash";
            command =
              "/run/current-system/sw/bin/blackbox -c display-custom-keybindings";
            name = "Show current custom keybindings in a terminal";
          };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom14" = {
          binding = "<Super><Shift>slash";
          command = "/home/${user-settings.user.username}/.local/bin/show-forge-shortcuts";
          name = "Show Forge Shortcuts";
        };

        # Forge Extensions Keybindings
        "org/gnome/shell/extensions/forge/keybindings" = {
          # Window focus
          window-focus-down = [ "<Super>j" ];
          window-focus-left = [ "<Super>h" ];
          window-focus-right = [ "<Super>l" ];
          window-focus-up = [ "<Super>k" ];

          # Gap size
          window-gap-size-decrease = [ "<Control><Super>minus" ];
          window-gap-size-increase = [ "<Control><Super>plus" ];

          # Window movement
          window-move-down = [ "<Shift><Super>j" ];
          window-move-left = [ "<Shift><Super>h" ];
          window-move-right = [ "<Shift><Super>l" ];
          window-move-up = [ "<Shift><Super>k" ];

          # Window resizing
          window-resize-bottom-decrease = [ "<Shift><Control><Super>i" ];
          window-resize-bottom-increase = [ "<Control><Super>u" ];
          window-resize-left-decrease = [ "<Shift><Control><Super>o" ];
          window-resize-left-increase = [ "<Control><Super>y" ];
          window-resize-right-decrease = [ "<Shift><Control><Super>y" ];
          window-resize-right-increase = [ "<Control><Super>o" ];
          window-resize-top-decrease = [ "<Shift><Control><Super>u" ];
          window-resize-top-increase = [ "<Control><Super>i" ];

          # Window snapping
          window-snap-center = [ "<Control><Alt>c" ];
          window-snap-one-third-left = [ "<Control><Alt>d" ];
          window-snap-one-third-right = [ "<Control><Alt>g" ];
          window-snap-two-third-left = [ "<Control><Alt>e" ];
          window-snap-two-third-right = [ "<Control><Alt>t" ];

          # Window swapping
          window-swap-down = [ "<Control><Super>j" ];
          window-swap-last-active = [ "<Super>Return" ];
          window-swap-left = [ "<Control><Super>h" ];
          window-swap-right = [ "<Control><Super>l" ];
          window-swap-up = [ "<Control><Super>k" ];

          # Window floating
          window-toggle-always-float = [ "<Shift><Super>c" ];
          window-toggle-float = [ "<Super>c" ];

          # Container layouts
          con-split-horizontal = [ "<Super>z" ];
          con-split-layout-toggle = [ "<Super>g" ];
          con-split-vertical = [ "<Super>v" ];
          con-stacked-layout-toggle = [ "<Shift><Super>s" ];
          con-tabbed-layout-toggle = [ "<Shift><Super>t" ];
          con-tabbed-showtab-decoration-toggle = [ "<Control><Alt>y" ];

          # Focus and workspace
          focus-border-toggle = [ "<Super>x" ];
          workspace-active-tile-toggle = [ "<Shift><Super>w" ];
          prefs-tiling-toggle = [ "<Super>w" ];

          # Mouse
          mod-mask-mouse-tile = "None";
        };


      };

    };

  };
}
