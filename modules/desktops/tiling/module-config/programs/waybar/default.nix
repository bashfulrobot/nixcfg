{pkgs, ...}: {
  fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];
  home-manager.sharedModules = [
    (_: {
      programs.waybar = {
        enable = true;
        systemd = {
          enable = false;
          target = "graphical-session.target";
        };
        settings = [
          {
            layer = "top";
            position = "top";
            mode = "dock"; # Fixes fullscreen issues
            # height = 28; # let waybar auto-calculate optimal height
            exclusive = true;
            passthrough = false;
            gtk-layer-shell = true;
            ipc = true;
            fixed-center = true;
            margin-top = 10;
            margin-left = 10;
            margin-right = 10;
            margin-bottom = 0;

            modules-left = ["hyprland/workspaces" "mpris"];
            modules-center = ["custom/notification" "clock"];
            modules-right = ["group/system-info" "custom/power"];

            "group/system-info" = {
              orientation = "inherit";
              drawer = {
                transition-duration = 500;
                children-class = "system-drawer";
                transition-left-to-right = false;
              };
              modules = ["custom/system-gear" "idle_inhibitor" "pulseaudio" "tray"];
            };

            "custom/system-gear" = {
              format = "{}";
              exec = "echo ⚙";
              interval = "once";
              tooltip = false;
            };

            "custom/notification" = {
              tooltip = false;
              format = "{icon}";
              format-icons = {
                notification = "<span foreground='red'><sup></sup></span>";
                none = "";
                dnd-notification = "<span foreground='red'><sup></sup></span>";
                dnd-none = "";
                inhibited-notification = "<span foreground='red'><sup></sup></span>";
                inhibited-none = "";
                dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
                dnd-inhibited-none = "";
              };
              return-type = "json";
              exec-if = "which swaync-client";
              exec = "swaync-client -swb";
              on-click = "swaync-client -t -sw";
              on-click-right = "swaync-client -d -sw";
              escape = true;
            };

            "custom/colour-temperature" = {
              format = "{} ";
              exec = "wl-gammarelay-rs watch {t}";
              on-scroll-up = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +100";
              on-scroll-down = "busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -100";
            };
            "custom/cava_mviz" = {
              exec = "${../../scripts/WaybarCava.sh}";
              format = "";
            };
            "cava" = {
              hide_on_silence = false;
              framerate = 60;
              bars = 10;
              format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
              input_delay = 1;
              # "noise_reduction" = 0.77;
              sleep_timer = 5;
              bar_delimiter = 0;
              on-click = "playerctl play-pause";
            };
            "custom/gpuinfo" = {
              exec = "${../../scripts/gpuinfo.sh}";
              return-type = "json";
              format = " {}";
              interval = 5; # once every 5 seconds
              tooltip = true;
              max-length = 1000;
            };
            "custom/icon" = {
              # format = " ";
              exec = "echo ' '";
              format = "";
            };
            "mpris" = {
              format = "{player_icon} {title} - {artist}";
              format-paused = "{status_icon} <i>{title} - {artist}</i>";
              format-stopped = "";
              player-icons = {
                default = "▶";
                spotify = "";
                mpv = "󰐹";
                vlc = "󰕼";
                firefox = "";
                chromium = "";
                kdeconnect = "";
                mopidy = "";
              };
              status-icons = {
                paused = "⏸";
                playing = "";
              };
              ignored-players = ["firefox" "chromium"];
              max-length = 35;
              tooltip-format = "{player}: {title} - {artist}\\nAlbum: {album}";
              on-click = "playerctl play-pause";
              on-scroll-up = "playerctl next";
              on-scroll-down = "playerctl previous";
            };



            "temperature" = {
              hwmon-path = "/sys/class/hwmon/hwmon5/temp1_input";
              critical-threshold = 83;
              format = "{icon} {temperatureC}°C";
              format-icons = ["" "" ""];
              interval = 10;
            };
            "hyprland/language" = {
              format = "{short}"; # can use {short} and {variant}
              on-click = "${../../scripts/keyboardswitch.sh}";
            };
            "hyprland/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
              active-only = false;
              on-click = "activate";
              show-special = false;
            };

            "hyprland/window" = {
              format = "  {}";
              separate-outputs = true;
              rewrite = {
                "harvey@hyprland =(.*)" = "$1 ";
                "(.*) — Mozilla Firefox" = "$1 󰈹";
                "(.*)Mozilla Firefox" = " Firefox 󰈹";
                "(.*) - Visual Studio Code" = "$1 󰨞";
                "(.*)Visual Studio Code" = "Code 󰨞";
                "(.*) — Dolphin" = "$1 󰉋";
                "(.*)Spotify" = "Spotify 󰓇";
                "(.*)Spotify Premium" = "Spotify 󰓇";
                "(.*)Steam" = "Steam 󰓓";
              };
              max-length = 1000;
            };

            "idle_inhibitor" = {
              format = "{icon}";
              format-icons = {
                activated = "󰥔";
                deactivated = "";
              };
            };

            "clock" = {
              format = "{:%a %d %b %R}";
              # format = "{:%R 󰃭 %d·%m·%y}";
              format-alt = "{:%I:%M %p}";
              tooltip-format = "<tt>{calendar}</tt>";
              calendar = {
                mode = "month";
                mode-mon-col = 3;
                on-scroll = 1;
                on-click-right = "mode";
                format = {
                  months = "<span color='#ffead3'><b>{}</b></span>";
                  weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                  today = "<span color='#ff6699'><b>{}</b></span>";
                };
              };
              actions = {
                on-click-right = "mode";
                on-click-forward = "tz_up";
                on-click-backward = "tz_down";
                on-scroll-up = "shift_up";
                on-scroll-down = "shift_down";
              };
            };

            "cpu" = {
              interval = 10;
              format = "󰍛 {usage}%";
              format-alt = "{icon0}{icon1}{icon2}{icon3}";
              format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            };

            "memory" = {
              interval = 30;
              format = "󰾆 {percentage}%";
              format-alt = "󰾅 {used}GB";
              max-length = 10;
              tooltip = true;
              tooltip-format = " {used:.1f}GB/{total:.1f}GB";
            };

            "backlight" = {
              format = "{icon} {percent}%";
              format-icons = ["" "" "" "" "" "" "" "" ""];
              on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set 2%+";
              on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 2%-";
            };

            "network" = {
              on-click = "ghostty --class floating-terminal nmtui";
              # "interface" = "wlp2*"; # (Optional) To force the use of this interface
              format-wifi = "󰤨 Wi-Fi";
              # format-wifi = " {bandwidthDownBits}  {bandwidthUpBits}";
              # format-wifi = "󰤨 {essid}";
              format-ethernet = "󱘖 Wired";
              # format-ethernet = " {bandwidthDownBits}  {bandwidthUpBits}";
              format-linked = "󱘖 {ifname} (No IP)";
              format-disconnected = "󰤮 Off";
              # format-disconnected = "󰤮 Disconnected";
              format-alt = "󰤨 {signalStrength}%";
              tooltip-format = "󱘖 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
            };

            "pulseaudio" = {
              format = "{icon}";
              format-muted = "󰝟";
              format-icons = {
                headphone = "󰋋";
                hands-free = "󰋎";
                headset = "󰋎";
                phone = "";
                portable = "";
                car = "";
                default = ["󰕿" "󰖀" "󰕾"];
              };
              scroll-step = 5;
              on-click = "pwvucontrol &";
              on-click-right = "bash -c 'selected=$(printf \"Open PipeWire Control\\nSwitch to Shure MV7\\nSwitch to rempods (AirPods)\\nSwitch to earmuffs\\nSwitch to Speakers\\nMixed Mode (MV7 + rempods)\\nMixed Mode (MV7 + earmuffs)\\nList Audio Devices\\nToggle Output Mute\\nToggle Input Mute\" | rofi -dmenu -p \"Audio Options\" -theme-str \"window {padding: 15px; margin: 10px;}\"); case \"$selected\" in \"Open PipeWire Control\") pwvucontrol & ;; \"Switch to Shure MV7\") mv7; hyprctl notify -1 3000 \"rgb(74c7ec)\" \"Switched to Shure MV7\" ;; \"Switch to rempods (AirPods)\") rempods; hyprctl notify -1 3000 \"rgb(74c7ec)\" \"Switched to rempods\" ;; \"Switch to earmuffs\") earmuffs; hyprctl notify -1 3000 \"rgb(74c7ec)\" \"Switched to earmuffs\" ;; \"Switch to Speakers\") speakers; hyprctl notify -1 3000 \"rgb(74c7ec)\" \"Switched to speakers\" ;; \"Mixed Mode (MV7 + rempods)\") mixed-mode-rempods; hyprctl notify -1 3000 \"rgb(f9e2af)\" \"Mixed mode: MV7 + rempods\" ;; \"Mixed Mode (MV7 + earmuffs)\") mixed-mode-earmuffs; hyprctl notify -1 3000 \"rgb(f9e2af)\" \"Mixed mode: MV7 + earmuffs\" ;; \"List Audio Devices\") ghostty --class floating-terminal -e bash -c \"audio-list; read -p \\\"Press Enter to close...\\\"\" ;; \"Toggle Output Mute\") pamixer -t; hyprctl notify -1 2000 \"rgb(f38ba8)\" \"Output mute toggled\" ;; \"Toggle Input Mute\") pamixer --default-source -t; hyprctl notify -1 2000 \"rgb(f38ba8)\" \"Input mute toggled\" ;; esac'";
              on-scroll-up = "pamixer -i 5";
              on-scroll-down = "pamixer -d 5";
              tooltip-format = "Source: {desc}\nVolume: {volume}%\nClick: Open PipeWire Control | Right-click: Audio menu | Scroll: Volume";
              max-volume = 150;
            };

            "battery" = {
              states = {
                good = 95;
                warning = 30;
                critical = 20;
              };
              format = "{icon}";
              format-alt = "{icon} {capacity}%";
              format-alt-click = "click-right";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
              on-click = "bash -c 'current=$(powerprofilesctl get 2>/dev/null || echo \"balanced\"); performance_option=\"Performance\"; balanced_option=\"Balanced\"; powersaver_option=\"Power Saver\"; case \"$current\" in \"performance\") performance_option=\"Performance ✓\"; ;; \"balanced\") balanced_option=\"Balanced ✓\"; ;; \"power-saver\") powersaver_option=\"Power Saver ✓\"; ;; esac; selected=$(printf \"%s\\n%s\\n%s\" \"$performance_option\" \"$balanced_option\" \"$powersaver_option\" | rofi -dmenu -p \"Power Profile\" -theme-str \"window {padding: 15px; margin: 10px;}\"); case \"$selected\" in *\"Performance\"*) powerprofilesctl set performance; notify-send \"Power Profile\" \"Switched to Performance mode\" -t 3000; ;; *\"Balanced\"*) powerprofilesctl set balanced; notify-send \"Power Profile\" \"Switched to Balanced mode\" -t 3000; ;; *\"Power Saver\"*) powerprofilesctl set power-saver; notify-send \"Power Profile\" \"Switched to Power Saver mode\" -t 3000; ;; esac'";
              tooltip-format = "Battery: {capacity}% | Time: {time} | Click for power profile";
            };

            "tray" = {
              icon-size = 16;
              spacing = 16;
            };

            "custom/power" = {
              format = "{}";
              on-click = "bash -c 'selected=$(printf \"Reboot\\nSuspend\\nShutdown\\nLogout\" | rofi -dmenu -p \"Power Options\" -theme-str \"window {padding: 15px; margin: 10px;}\"); case \"$selected\" in \"Reboot\") systemctl reboot; ;; \"Suspend\") systemctl suspend; ;; \"Shutdown\") systemctl poweroff; ;; \"Logout\") hyprctl dispatch exit 0; ;; esac'";
              tooltip-format = "Power Options (click for menu)";
            };
          }
        ];
        style = ''
          /* =============================================================================
           *
           * Waybar configuration
           *
           * ===========================================================================*/

          * {
              font-family: "JetBrainsMono Nerd Font";
              font-size: 11px;
              font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
              margin: 0px;
              padding: 0px;
          }

          window#waybar {
              transition-property: background-color;
              transition-duration: 0.5s;
              background: transparent;
              border-radius: 10px;
          }

          window#waybar.hidden {
              opacity: 0.2;
          }

          tooltip {
              border-radius: 8px;
          }

          tooltip label {
              margin-right: 5px;
              margin-left: 5px;
          }


          /* --- Module Container Styling --- */
          .modules-left,
          .modules-center,
          .modules-right {
              background: @theme_base_color;
              border: 1px solid @blue;
              padding: 0 15px;
              border-radius: 10px;
          }

          .modules-center {
              border: 0.5px solid @overlay0;
              padding: 0 10px;
          }

          /* --- Generic Module Styling --- */
          #workspaces,
          #idle_inhibitor,
          #mpris,
          #clock,
          #pulseaudio,
          #battery,
          #tray {
              padding: 1px 10px;
              margin: 0 1.5px;
          }

          /* --- Specific Module Styling --- */

          /* -- Workspaces -- */
          #workspaces button {
              box-shadow: none;
              text-shadow: none;
              padding: 1px 8px;
              margin: 0 1px;
              border-radius: 6px;
              background-color: transparent;
              border: 1px solid transparent;
              transition: all 0.2s ease-in-out;
              font-weight: normal;
          }

          #workspaces button .workspace-label {
              color: @overlay1; /* Default text color */
          }

          #workspaces button:hover {
              background-color: @surface1;
              border: none;
          }

          #workspaces button:hover .workspace-label {
              color: @text;
          }

          #workspaces button.persistent .workspace-label {
              color: @overlay0;
          }

          #workspaces button.occupied {
              background-color: @surface0;
              font-weight: 500;
          }

          #workspaces button.occupied .workspace-label {
              color: @blue;
          }

          #workspaces button.active {
              background-color: @blue;
              border-radius: 0px;
              font-weight: bold;
          }

          #workspaces button.active .workspace-label {
              color: @text;
          }

          #workspaces button.urgent {
              background-color: @red;
              animation: urgent-pulse 1s ease-in-out infinite alternate;
          }

          #workspaces button.urgent .workspace-label {
              color: @theme_base_color;
          }

          @keyframes urgent-pulse {
              from { opacity: 1; }
              to { opacity: 0.6; }
          }

          @keyframes attention-pulse {
              from { opacity: 1.0; }
              to { opacity: 0.6; }
          }

          /* -- Other Modules -- */
          #idle_inhibitor {
              color: @overlay1;
              transition: color 0.3s ease-in-out;
          }

          #idle_inhibitor:hover {
              background-color: @surface1;
              color: @text;
          }

          #idle_inhibitor.activated {
              color: @green;
              font-weight: 500;
          }

          #idle_inhibitor.deactivated {
              color: @overlay0;
              opacity: 0.7;
          }

          #battery {
              color: @green;
              transition: all 0.3s ease-in-out;
              border-radius: 6px;
              padding: 2px 8px;
          }

          #battery:hover {
              background-color: @surface1;
              color: @text;
          }

          #battery.good {
              color: @green;
          }

          #battery.warning {
              color: @yellow;
              font-weight: 500;
          }

          #battery.critical {
              color: @red;
              font-weight: bold;
          }

          #battery.charging {
              color: @blue;
              background-color: @surface0;
          }


          #clock {
              color: @yellow;
              font-weight: 500;
              transition: all 0.2s ease-in-out;
              border-radius: 6px;
              padding: 2px 8px;
          }

          #clock:hover {
              background-color: @surface1;
              color: @text;
          }

          #mpris {
              color: @pink;
              font-style: italic;
              transition: all 0.2s ease-in-out;
              border-radius: 6px;
              padding: 2px 8px;
          }

          #mpris:hover {
              background-color: @surface1;
              color: @text;
              font-style: normal;
          }

          #mpris.paused {
              color: @overlay1;
              opacity: 0.8;
          }

          #mpris.playing {
              color: @pink;
              font-weight: 500;
          }



          #tray {
              padding: 2px 8px;
              border-radius: 6px;
              transition: background-color 0.2s ease-in-out;
          }

          #tray:hover {
              background-color: @surface1;
          }

          #tray > .passive:hover {
              color: @text;
          }

          #tray > .active:hover {
              color: @text;
          }

          #tray > .passive {
              -gtk-icon-effect: dim;
              opacity: 0.7;
          }

          #tray > .active {
              -gtk-icon-effect: none;
              opacity: 1.0;
          }

          #tray > .needs-attention {
              -gtk-icon-effect: highlight;
              color: @yellow;
              animation: attention-pulse 1.5s ease-in-out infinite alternate;
          }


          #custom-notification {
              color: @overlay1;
              transition: all 0.2s ease-in-out;
              border-radius: 6px;
              padding: 2px 8px;
              margin: 0 1.5px;
          }

          #custom-notification:hover {
              background-color: @surface1;
              color: @text;
          }

          #custom-power {
              color: @red;
              border-left: 1px solid @blue;
              padding: 2px 8px 2px 12px;
              margin-left: 12px;
              border-radius: 0 6px 6px 0;
              transition: all 0.2s ease-in-out;
          }

          #custom-power:hover {
              background-color: @surface1;
              color: @text;
          }


          #pulseaudio {
              color: @lavender;
              transition: all 0.2s ease-in-out;
              border-radius: 6px;
              padding: 2px 8px;
          }

          #pulseaudio:hover {
              background-color: @surface1;
              color: @text;
          }

          #pulseaudio.muted {
              color: @red;
              background-color: @surface0;
          }

          #pulseaudio.bluetooth {
              color: @pink;
              background-color: @surface0;
          }

          #pulseaudio.source-muted {
              color: @orange;
              font-style: italic;
          }


          /* -- Group Styling -- */
          group#system-info {
              border-radius: 6px;
              transition: all 0.2s ease-in-out;
          }

          .system-drawer {
              padding: 2px 8px;
              margin: 0 1.5px;
              transition: all 0.2s ease-in-out;
          }

          .system-drawer:first-child {
              border-radius: 6px 0 0 6px;
          }

          .system-drawer:last-child {
              border-radius: 0 6px 6px 0;
          }

          .system-drawer:only-child {
              border-radius: 6px;
          }

          group#system-info:hover .system-drawer {
              background-color: @surface1;
          }

          #custom-system-gear {
              color: @overlay1;
              font-size: 14px;
              padding: 2px 8px 2px 12px;
              margin: 0 1.5px;
              margin-right: 12px;
              border-radius: 6px;
              transition: all 0.2s ease-in-out;
          }

          #custom-system-gear:hover {
              color: @text;
              background-color: @surface1;
          }


          /* -- Animations -- */
          @keyframes blink {
              to {
                  color: @surface0;
              }
          }

          #battery.critical:not(.charging) {
              background-color: @red;
              color: @theme_base_color;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
              box-shadow: inset 0 -3px transparent;
          }

        '';
      };
    })
  ];
}