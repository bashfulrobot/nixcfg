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
  makeCommand = command: { command = [ command ]; };
  settingsJson = builtins.fromJSON (builtins.readFile ./settings/settings.json);

in
{

  # NixOS Configuration
  programs.niri = {
    enable = true;
  };

  home-manager.users."${user-settings.user.username}" = {
    # Home Manager Configuration
    programs.niri = {

      enable = true;

      settings = {
        environment = {
          DISPLAY = ":0";
          QT_QPA_PLATFORM = "wayland";
          XDG_CURRENT_DESKTOP = "niri";
          XDG_SESSION_TYPE = "wayland";
          # Better app compatibility
          NIXOS_OZONE_WL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          NIRI_SESSION = "1";
        };

        spawn-at-startup = [
          (makeCommand "blueman-applet")
          (makeCommand "swww img ${config.sys.wallpapers.getWallpaper "personal"}")
          (makeCommand "xwayland-satellite")
        ];

        outputs = {
          # Laptop ...
          "eDP-1" = {
            scale = 2.0;
            position = {
              x = 0;
              y = 0;
            };
          };

          # Office Monitors
          "DP-1" = {
            scale = 2.0;
            position = {
              x = 0;
              # Logical size of Teleprompter is x540, due to 2xScale
              y = 540;
            };
            focus-at-startup = true;
          };

          "DP-2" = {
            scale = 2.0;
            position = {
              x = 1920;
              y = 540;
            };
          };

          # This is my Teleprompter monitor
          "Invalid Vendor Codename - RTK Field Monitor J257M96B00FL" = {
            scale = 2.0;
            mode = {
              width = 1920;
              height = 1080;
              refresh = 60.0;
            };
            transform.rotation = 180;
            position = {
              x = 0;
              y = 0;
            };
          };

          # Monitor for my laptop at home
          "Samsung Electric Company LS32A70 HK2WB00305" = {
            scale = 1.75;
          };
        };

        # Nix attribute sets are ordered alphabetically when evaludated,
        # so we use 01/02/etc to force the order of workspaces; which Niri
        # relies on to determine the order of workspaces.
        workspaces = {
          "01" = {
            name = "Web";
            open-on-output = "DP-1";
          };

          "02" = {
            name = "Code";
            open-on-output = "DP-2";
          };

          "03" = {
            name = "Chat";
            open-on-output = "DP-1";
          };
        };

        input = {
          keyboard = {
            numlock = true;
            track-layout = "window";
          };
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
            accel-profile = "adaptive";
            scroll-method = "two-finger";
          };
          mouse = {
            natural-scroll = true;
            accel-profile = "adaptive";
          };
        };

        cursor = {
          hide-when-typing = true;
          hide-after-inactive-ms = 1000;
        };

        hotkey-overlay = {
          skip-at-startup = true;
        };

        prefer-no-csd = true;

        # Screenshot configuration
        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        animations = {
          slowdown = 0.6;
        };

        overview = {
          zoom = 0.32;
        };

        layout = {
          gaps = 8;

          border.enable = true;

          center-focused-column = "never";

          struts = {
            left = 8;
            right = 8;
            top = 8;
            bottom = 8;
          };

          default-column-width = {
            proportion = 1.0;
          };

          preset-column-widths = [
            { proportion = 0.5; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];

          preset-window-heights = [
            { proportion = 0.5; }
            { proportion = 0.75; }
            { proportion = 1.0; }
          ];
        };

        switch-events = {
          lid-close = {
            action = {
              spawn = [
                "systemctl"
                "suspend"
              ];
            };
          };
        };

        window-rules = [
          {
            matches = [
              { app-id = "vivaldi"; }
              { app-id = "vivaldi-stable"; }
              { app-id = "firefox"; }
            ];
            open-on-workspace = "Web";
            open-focused = true;
            open-maximized = true;
          }
          {
            matches = [
              {
                app-id = "firefox$";
                title = "^Picture-in-Picture$";
              }
            ];
            open-floating = true;
          }
          {
            matches = [
              { app-id = "com.slack.Slack"; }
              { app-id = "org.zulip.Zulip"; }
            ];
            open-on-workspace = "Chat";
            open-focused = true;
            open-maximized = true;
          }
          {
            matches = [ { app-id = "Zoom Workplace"; } ];
            excludes = [
              { title = "Zoom Meeting"; }
              { title = "Meeting"; }
            ];
            open-floating = true;
            open-focused = false;
          }
          {
            matches = [
              { app-id = "code"; }
            ];
            open-on-workspace = "Code";
            open-focused = true;
            open-maximized = true;
          }
          {
            matches = [
              { app-id = "com.mitchellh.ghostty"; }
            ];
            open-focused = true;
            open-maximized = false;
          }
          {
            matches = [
              { is-floating = true; }
            ];
            geometry-corner-radius = {
              top-left = 16.0;
              top-right = 16.0;
              bottom-right = 16.0;
              bottom-left = 16.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [
              { is-window-cast-target = true; }
            ];
            shadow = {
              color = "#d75f5e40";
            };
          }
          {
            matches = [
              { app-id = "1Password"; }
              { title = "[Gg]mail"; }
              { app-id = ".*[Ss]waync.*"; }
            ];
            block-out-from = "screen-capture";
          }
          {
            matches = [
              { is-floating = false; }
            ];
            geometry-corner-radius = {
              top-left = 10.0;
              top-right = 10.0;
              bottom-right = 10.0;
              bottom-left = 10.0;
            };
            clip-to-geometry = true;
            shadow = {
              enable = true;
              color = "#00000060";
              softness = 10;
              spread = 3;
              offset = {
                x = 0;
                y = 3;
              };
              draw-behind-window = true;
            };
          }
          # Additional advanced window rules
          {
            matches = [{ app-id = "^org\\.kde\\..*"; }];
            default-column-width = { proportion = 0.75; };
          }
          {
            matches = [
              { title = "^(Picture.in.Picture|PiP).*"; }
              { title = "^Picture-in-Picture$"; }
            ];
            open-floating = true;
            geometry-corner-radius = {
              top-left = 8.0;
              top-right = 8.0;
              bottom-left = 8.0;
              bottom-right = 8.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [
              { app-id = "^(pavucontrol|blueman-manager)$"; }
            ];
            open-floating = true;
          }
          {
            matches = [{ is-focused = true; }];
          }
          {
            matches = [{ is-focused = false; }];
          }
        ];

        binds = {
          "Super+Q" = {
            action.close-window = { };
          };
          "Super+Shift+Q" = {
            action.quit = { };
          };
          "Super+Space" = {
            action = {
              spawn = [ "fuzzel" ];
            };
          };
          "Super+C" = {
            action = {
              spawn = [
                "bash"
                "-c"
                "cliphist list | fuzzel --dmenu --prompt='Copy to Clipboard:' | cliphist decode | wl-copy"
              ];
            };
          };
          "Super+T" = {
            action = {
              spawn = [ "ghostty" ];
            };
          };

          "Super+Shift+Space" = {
            action = {
              spawn = [ "com.jeffser.Alpaca --live-chat" ];
            };
          };

          "Super+E" = {
            action = {
              spawn = [ "bemoji" ];
            };
          };

          "Super+Z" = {
            action = {
              spawn = [ "${lib.getExe pkgs.nautilus}" ];
            };
          };
          "Super+P" = {
            action = {
              spawn = [ "${lib.getExe pkgs.hyprpicker}" ];
            };
          };

          "Ctrl+Down" = {
            action.toggle-overview = { };
          };
          "Super+N" = {
            action = {
              spawn = [
                "swaync-client"
                "-t"
              ];
            };
          };
          "Super+Return" = {
            action = {
              spawn = [ "ghostty" ];
            };
          };
          "Super+Backslash" = {
            action = {
              spawn = [
                "1password"
                "--quick-access"
              ];
            };
          };
          "Super+Comma" = {
            action.consume-window-into-column = { };
          };
          "Super+Period" = {
            action.expel-window-from-column = { };
          };
          "Super+Page_Up" = {
            action.focus-workspace-up = { };
          };
          "Super+Page_Down" = {
            action.focus-workspace-down = { };
          };
          "Super+Shift+Page_Up" = {
            action.move-column-to-workspace-up = { };
          };
          "Super+Shift+Page_Down" = {
            action.move-column-to-workspace-down = { };
          };
          "Super+Control+Down" = {
            action.move-column-to-monitor-down = { };
          };
          "Super+Control+Up" = {
            action.move-column-to-monitor-up = { };
          };
          "Super+Control+Left" = {
            action.move-column-to-monitor-left = { };
          };
          "Super+Control+Right" = {
            action.move-column-to-monitor-right = { };
          };
          "Super+Up" = {
            action.focus-window-up = { };
          };
          "Super+Down" = {
            action.focus-window-down = { };
          };
          "Super+Left" = {
            action.focus-column-left = { };
          };
          "Super+Shift+Left" = {
            action.move-column-left = { };
          };
          "Super+Right" = {
            action.focus-column-right = { };
          };
          "Super+Shift+Right" = {
            action.move-column-right = { };
          };

          # Vim-style navigation
          "Super+K" = {
            action.focus-window-up = { };
          };
          "Super+J" = {
            action.focus-window-down = { };
          };
          "Super+H" = {
            action.focus-column-left = { };
          };
          "Super+Shift+H" = {
            action.move-column-left = { };
          };
          "Super+L" = {
            action.focus-column-right = { };
          };
          "Super+1" = {
            action.focus-workspace = 1;
          };
          "Super+2" = {
            action.focus-workspace = 2;
          };
          "Super+3" = {
            action.focus-workspace = 3;
          };
          "Super+4" = {
            action.focus-workspace = 4;
          };
          "Super+5" = {
            action.focus-workspace = 5;
          };
          "Super+6" = {
            action.focus-workspace = 6;
          };
          "Super+7" = {
            action.focus-workspace = 7;
          };
          "Super+8" = {
            action.focus-workspace = 8;
          };
          "Super+9" = {
            action.focus-workspace = 9;
          };
          "Super+Shift+1" = {
            action.move-column-to-workspace = 1;
          };
          "Super+Shift+2" = {
            action.move-column-to-workspace = 2;
          };
          "Super+Shift+3" = {
            action.move-column-to-workspace = 3;
          };
          "Super+Shift+4" = {
            action.move-column-to-workspace = 4;
          };
          "Super+Shift+5" = {
            action.move-column-to-workspace = 5;
          };
          "Super+Shift+6" = {
            action.move-column-to-workspace = 6;
          };
          "Super+Shift+7" = {
            action.move-column-to-workspace = 7;
          };
          "Super+Shift+8" = {
            action.move-column-to-workspace = 8;
          };
          "Super+Shift+9" = {
            action.move-column-to-workspace = 9;
          };
          "Super+F" = {
            action.fullscreen-window = { };
          };
          "Super+R" = {
            action.switch-preset-column-width = { };
          };
          "Super+Shift+R" = {
            action.switch-preset-window-height = { };
          };
          "Ctrl+Shift+Space" = {
            action.toggle-window-floating = { };
          };
          "Print" = {
            action.screenshot-window = { };
          };
          "Super+Print" = {
            action.screenshot = { };
          };
          # Secondary screenshot shortcuts for keyboards without Print key
          "Super+Shift+S" = {
            action = {
              spawn = [
                "bash"
                "-c"
                "grim -g \"$(slurp)\" - | wl-copy"
              ];
            };
          };
          "Super+Shift+Print" = {
            action.screenshot = { };
          };

          # Media controls with proper SwayOSD integration
          "XF86AudioPlay" = {
            action = {
              spawn = [
                "swayosd-client"
                "--player-status"
                "play-pause"
              ];
            };
          };
          "XF86AudioPause" = {
            action = {
              spawn = [
                "swayosd-client"
                "--player-status"
                "play-pause"
              ];
            };
          };
          "XF86AudioNext" = {
            action = {
              spawn = [
                "swayosd-client"
                "--player-status"
                "next"
              ];
            };
          };
          "XF86AudioPrev" = {
            action = {
              spawn = [
                "swayosd-client"
                "--player-status"
                "previous"
              ];
            };
          };

          # Volume controls with OSD
          "XF86AudioRaiseVolume" = {
            action = {
              spawn = [
                "swayosd-client"
                "--output-volume"
                "raise"
              ];
            };
          };
          "XF86AudioLowerVolume" = {
            action = {
              spawn = [
                "swayosd-client"
                "--output-volume"
                "lower"
              ];
            };
          };
          "XF86AudioMute" = {
            action = {
              spawn = [
                "swayosd-client"
                "--output-volume"
                "mute-toggle"
              ];
            };
          };
          "XF86AudioMicMute" = {
            action = {
              spawn = [
                "swayosd-client"
                "--input-volume"
                "mute-toggle"
              ];
            };
          };

          # Brightness controls with OSD
          "XF86MonBrightnessUp" = {
            action = {
              spawn = [
                "swayosd-client"
                "--brightness"
                "raise"
              ];
            };
          };
          "XF86MonBrightnessDown" = {
            action = {
              spawn = [
                "swayosd-client"
                "--brightness"
                "lower"
              ];
            };
          };

          "Num_Lock" = {
            action = {
              spawn = [
                "swayosd-client"
                "--num-lock"
                "toggle"
              ];
            };
          };

          # Custom system monitoring with swayosd
          "Super+F1" = {
            action = {
              spawn = [
                "swayosd-custom"
                "battery"
              ];
            };
          };
          "Super+F2" = {
            action = {
              spawn = [
                "swayosd-custom"
                "memory-usage"
              ];
            };
          };
          "Super+F3" = {
            action = {
              spawn = [
                "swayosd-custom"
                "cpu-temp"
              ];
            };
          };
          "Super+F4" = {
            action = {
              spawn = [
                "swayosd-custom"
                "disk-usage"
              ];
            };
          };
          "Super+Shift+F1" = {
            action = {
              spawn = [
                "swayosd-custom"
                "microphone-volume"
              ];
            };
          };
          "Super+Shift+F2" = {
            action = {
              spawn = [
                "swayosd-custom"
                "wifi-strength"
              ];
            };
          };

          # Screencasting controls
          "Super+Shift+W" = {
            action.toggle-windowed-fullscreen = { };
          };
          "Super+Shift+C" = {
            action.set-dynamic-cast-window = { };
          };
          "Super+Shift+M" = {
            action.set-dynamic-cast-monitor = { };
          };
          "Super+Shift+Escape" = {
            action.clear-dynamic-cast-target = { };
          };

          # Keyboard shortcuts help menu
          "Super+Shift+Slash" = {
            action = {
              spawn = [ "${pkgs.bash}/bin/bash" "/home/dustin/dev/nix/nixcfg/modules/desktops/tiling/module-config/scripts/niri-shortcuts-menu.sh" ];
            };
          };
        };
      };
    };
  };
}
