{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.desktops.tiling.niri;

in
{
  options = {
    desktops.tiling.niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri tiling Wayland compositor";
    };
  };

  imports = [
    ./module-config
  ];

  config = lib.mkIf cfg.enable {
    # NixOS Configuration
    programs.niri = {
      enable = true;
    };

    # Enable D-Bus for proper desktop session integration
    services.dbus.enable = true;

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    sys = {
      dconf.enable = true;
      stylix-theme.enable = true;
      xdg.enable = true;
    };

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

    home-manager.users."${user-settings.user.username}" = {
      # Home Manager Configuration
      programs.niri = {
        settings = {
          # Environment variables
          environment = {
            DISPLAY = ":0";
            QT_QPA_PLATFORM = "wayland";
            XDG_CURRENT_DESKTOP = "niri";
            XDG_SESSION_TYPE = "wayland";
          };

          # Spawn at startup
          spawn-at-startup = [
            { command = [ "blueman-applet" ]; }
            { command = [ "waybar" ]; }
          ];

          # Input configuration
          input = {
            keyboard.numlock = true;
            focus-follows-mouse = {
              enable = true;
              max-scroll-amount = "0%";
            };
            touchpad = {
              tap = true;
              natural-scroll = true;
              click-method = "clickfinger";
              dwt = true;
              disabled-on-external-mouse = true;
            };
            mouse.natural-scroll = true;
          };

          # Layout settings
          layout = {
            gaps = 16;
            border.enable = true;
            center-focused-column = "on-overflow";
            struts = {
              left = 64;
              right = 64;
              top = 4;
              bottom = 4;
            };
          };

          # Cursor behavior
          cursor = {
            hide-when-typing = true;
            hide-after-inactive-ms = 1000;
          };

          # Animations
          animations.slowdown = 0.6;

          # Window rules
          window-rules = [
            {
              matches = [{ app-id = "^org\\.gnome\\.Nautilus$"; }];
              default-column-width = { proportion = 0.5; };
            }
            {
              matches = [{ app-id = "^firefox$"; }];
              open-on-workspace = "Web";
            }
            {
              matches = [{ app-id = "^code$"; }];
              open-on-workspace = "Code";
            }
          ];

          # Workspaces
          workspaces = {
            "Web" = {};
            "Code" = {};
            "Chat" = {};
          };

          # Keybindings
          binds = let
            sh = cmd: [ "sh" "-c" cmd ];
          in {
            "Mod+Return".action.spawn = [ "ghostty" ];
            "Mod+Space".action.spawn = [ "fuzzel" ];
            "Mod+Shift+Space".action.spawn = [ "fuzzel-window-picker" ];

            # Window management
            "Mod+H".action.focus-column-left = {};
            "Mod+L".action.focus-column-right = {};
            "Mod+J".action.focus-window-down = {};
            "Mod+K".action.focus-window-up = {};

            "Mod+Shift+H".action.move-column-left = {};
            "Mod+Shift+L".action.move-column-right = {};
            "Mod+Shift+J".action.move-window-down = {};
            "Mod+Shift+K".action.move-window-up = {};

            # Workspace switching
            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;

            "Mod+Shift+1".action.move-column-to-workspace = 1;
            "Mod+Shift+2".action.move-column-to-workspace = 2;
            "Mod+Shift+3".action.move-column-to-workspace = 3;
            "Mod+Shift+4".action.move-column-to-workspace = 4;
            "Mod+Shift+5".action.move-column-to-workspace = 5;

            # System controls
            "Mod+Q".action.close-window = {};
            "Mod+F".action.maximize-column = {};
            "Mod+Shift+F".action.fullscreen-window = {};

            # Screenshots
            "Print".action.spawn = sh "grim - | wl-copy";
            "Shift+Print".action.spawn = sh "grim -g \"$(slurp)\" - | wl-copy";

            # Volume controls
            "XF86AudioRaiseVolume".action.spawn = sh "swayosd-client --output-volume raise";
            "XF86AudioLowerVolume".action.spawn = sh "swayosd-client --output-volume lower";
            "XF86AudioMute".action.spawn = sh "swayosd-client --output-volume mute-toggle";

            # Brightness controls
            "XF86MonBrightnessUp".action.spawn = sh "swayosd-client --brightness raise";
            "XF86MonBrightnessDown".action.spawn = sh "swayosd-client --brightness lower";
          };
        };
      };

      # Services
      services = {
        cliphist = {
          enable = true;
          systemdTarget = "niri-session.target";
        };

        swayosd = {
          enable = true;
          systemdTarget = "niri-session.target";
        };

        hypridle = {
          enable = true;
          settings = {
            general = {
              after_sleep_cmd = "niri msg action power-off-monitors";
              before_sleep_cmd = "niri msg action power-off-monitors";
              lock_cmd = "swaylock -f";
            };
            listener = [
              {
                timeout = 300;
                on-timeout = "swaylock -f";
              }
              {
                timeout = 600;
                on-timeout = "niri msg action power-off-monitors";
                on-resume = "niri msg action power-on-monitors";
              }
            ];
          };
        };

        gnome-keyring = {
          enable = true;
          components = [
            "pkcs11"
            "secrets"
            "ssh"
          ];
        };
      };

      # Additional environment variables for Wayland
      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        GDK_BACKEND = "wayland";
        XDG_SESSION_TYPE = "wayland";
        WLR_NO_HARDWARE_CURSORS = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };
    };
  };
}
