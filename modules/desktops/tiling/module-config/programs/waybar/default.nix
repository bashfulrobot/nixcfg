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

            modules-left = ["hyprland/workspaces"];
            # modules-center = ["clock" "custom/notification"];
            modules-center = ["idle_inhibitor" "clock"];
            modules-right = ["pulseaudio" /* "custom/gpuinfo" "cpu" "memory" "backlight" */ "battery" "tray" "custom/notification" "custom/power"];

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
              max-length = 30;
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
              on-click = "kitty --class floating-terminal nmtui";
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
              on-click-right = "bash -c 'selected=$(printf \"🔧 Open PipeWire Control\\n🎤 Switch to Shure MV7\\n🎧 Switch to rempods (AirPods)\\n🎧 Switch to earmuffs\\n🔊 Switch to Speakers\\n🎤🎧 Mixed Mode (MV7 + rempods)\\n🎤🎧 Mixed Mode (MV7 + earmuffs)\\n📋 List Audio Devices\\n🔇 Toggle Output Mute\\n🎤 Toggle Input Mute\" | rofi -dmenu -p \"Audio Options\" -theme-str \"window {width: 450px;}\"); case \"$selected\" in \"🔧 Open PipeWire Control\") pwvucontrol & ;; \"🎤 Switch to Shure MV7\") mv7; hyprctl notify -1 3000 \"rgb(74c7ec)\" \"🎤 Switched to Shure MV7\" ;; \"🎧 Switch to rempods (AirPods)\") rempods; hyprctl notify -1 3000 \"rgb(74c7ec)\" \"🎧 Switched to rempods\" ;; \"🎧 Switch to earmuffs\") earmuffs; hyprctl notify -1 3000 \"rgb(74c7ec)\" \"🎧 Switched to earmuffs\" ;; \"🔊 Switch to Speakers\") speakers; hyprctl notify -1 3000 \"rgb(74c7ec)\" \"🔊 Switched to speakers\" ;; \"🎤🎧 Mixed Mode (MV7 + rempods)\") mixed-mode-rempods; hyprctl notify -1 3000 \"rgb(f9e2af)\" \"🎤🎧 Mixed mode: MV7 + rempods\" ;; \"🎤🎧 Mixed Mode (MV7 + earmuffs)\") mixed-mode-earmuffs; hyprctl notify -1 3000 \"rgb(f9e2af)\" \"🎤🎧 Mixed mode: MV7 + earmuffs\" ;; \"📋 List Audio Devices\") kitty --class floating-terminal -e bash -c \"audio-list; read -p \\\"Press Enter to close...\\\"\" ;; \"🔇 Toggle Output Mute\") pamixer -t; hyprctl notify -1 2000 \"rgb(f38ba8)\" \"🔇 Output mute toggled\" ;; \"🎤 Toggle Input Mute\") pamixer --default-source -t; hyprctl notify -1 2000 \"rgb(f38ba8)\" \"🎤 Input mute toggled\" ;; esac'";
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
              format = "{icon} {capacity}%";
              format-charging = " {capacity}%";
              format-plugged = " {capacity}%";
              format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
              on-click = "bash -c 'current=$(powerprofilesctl get 2>/dev/null || echo \"balanced\"); performance_option=\"🚀 Performance\"; balanced_option=\"⚖️ Balanced\"; powersaver_option=\"🔋 Power Saver\"; case \"$current\" in \"performance\") performance_option=\"🚀 Performance ✓\"; ;; \"balanced\") balanced_option=\"⚖️ Balanced ✓\"; ;; \"power-saver\") powersaver_option=\"🔋 Power Saver ✓\"; ;; esac; selected=$(printf \"%s\\n%s\\n%s\" \"$performance_option\" \"$balanced_option\" \"$powersaver_option\" | rofi -dmenu -p \"Power Profile\" -theme-str \"window {width: 300px;}\"); case \"$selected\" in *\"Performance\"*) powerprofilesctl set performance; notify-send \"🚀 Power Profile\" \"Switched to Performance mode\" -t 3000; ;; *\"Balanced\"*) powerprofilesctl set balanced; notify-send \"⚖️ Power Profile\" \"Switched to Balanced mode\" -t 3000; ;; *\"Power Saver\"*) powerprofilesctl set power-saver; notify-send \"🔋 Power Profile\" \"Switched to Power Saver mode\" -t 3000; ;; esac'";
              on-click-right = "swaync-client -t";
              tooltip-format = "Battery: {capacity}% | Time: {time} | Click for power profile";
            };

            "tray" = {
              icon-size = 12;
              spacing = 16;
            };

            "custom/power" = {
              format = "{}";
              on-click = "bash -c 'selected=$(printf \"🔁 Reboot\\n⏸️ Suspend\\n🔌 Shutdown\\n🚪 Logout\" | rofi -dmenu -p \"Power Options\" -theme-str \"window {width: 250px;}\"); case \"$selected\" in *\"Reboot\"*) systemctl reboot; ;; *\"Suspend\"*) systemctl suspend; ;; *\"Shutdown\"*) systemctl poweroff; ;; *\"Logout\"*) hyprctl dispatch exit 0; ;; esac'";
              tooltip-format = "Power Options (click for menu)";
            };
          }
        ];
        style = ''
          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 11px;
            font-feature-settings: '"zero", "ss01", "ss02", "ss03", "ss04", "ss05", "cv31"';
            margin: 0px;
            padding: 0px;
          }

          /* Colors managed by stylix - remove hardcoded Catppuccin palette */

          window#waybar {
            transition-property: background-color;
            transition-duration: 0.5s;
            background: transparent;
            /*border: 2px solid @overlay0;*/
            /*background: @theme_base_color;*/
            border-radius: 10px;
          }

          window#waybar.hidden {
            opacity: 0.2;
          }

          tooltip {
            border-radius: 8px;
            /* background color managed by stylix */
          }

          tooltip label {
            margin-right: 5px;
            margin-left: 5px;
            /* color managed by stylix */
          }

          /* This section can be use if you want to separate waybar modules */
          .modules-left {
          	background: @theme_base_color;
           	border: 1px solid @blue;
          	padding-right: 15px;
          	padding-left: 8px;
          	border-radius: 10px;
          }
          .modules-center {
          	background: @theme_base_color;
            border: 0.5px solid @overlay0;
          	padding-right: 10px;
          	padding-left: 10px;
          	border-radius: 10px;
          }
          .modules-right {
          	background: @theme_base_color;
           	border: 1px solid @blue;
          	padding-right: 15px;
          	padding-left: 15px;
          	border-radius: 10px;
          }

          #backlight,
          #backlight-slider,
          #battery,
          #clock,
          #cpu,
          #disk,
          #idle_inhibitor,
          #keyboard-state,
          #memory,
          #mode,
          #mpris,
          #network,
          #pulseaudio,
          #pulseaudio-slider,
          #taskbar button,
          #taskbar,
          #temperature,
          #tray,
          #window,
          #wireplumber,
          #workspaces,
          #custom-backlight,
          #custom-cycle_wall,
          #custom-keybinds,
          #custom-keyboard,
          #custom-light_dark,
          #custom-lock,
          #custom-menu,
          #custom-power_vertical,
          #custom-power,
          #custom-swaync,
          #custom-updater,
          #custom-weather,
          #custom-weather.clearNight,
          #custom-weather.cloudyFoggyDay,
          #custom-weather.cloudyFoggyNight,
          #custom-weather.default,
          #custom-weather.rainyDay,
          #custom-weather.rainyNight,
          #custom-weather.severe,
          #custom-weather.showyIcyDay,
          #custom-weather.snowyIcyNight,
          #custom-weather.sunnyDay {
          	padding-top: 1px;
          	padding-bottom: 1px;
          	padding-right: 10px;
          	padding-left: 10px;
          	margin: 0 1.5px;
          }

          #idle_inhibitor {
            color: @blue;
          }

          #backlight {
            color: @blue;
          }

          #battery {
            color: @green;
          }

          @keyframes blink {
            to {
              color: @surface0;
            }
          }

          #battery.critical:not(.charging) {
            background-color: @red;
            color: @theme_text_color;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
            box-shadow: inset 0 -3px transparent;
          }

          #custom-updates {
            color: @blue
          }

          #custom-notification {
            color: @text;
            padding: 4px 10px;
            border-radius: 5px;
          }

          #language {
            color: @blue
          }

          #clock {
            color: @yellow;
          }

          #custom-icon {
            font-size: 15px;
            color: @lavender;
          }

          #custom-gpuinfo {
            color: @maroon;
          }

          #cpu {
            color: @yellow;
          }

          #custom-keyboard,
          #memory {
            color: @green;
          }

          #disk {
            color: @sapphire;
          }

          #temperature {
            color: @teal;
          }

          #temperature.critical {
            background-color: @red;
          }

          #tray {
            color: @text;
            padding: 1px 10px;
            margin: 0 1.5px;
          }
          
          #tray > .passive {
            -gtk-icon-effect: none;
            color: @text;
          }
          
          #tray > .needs-attention {
            -gtk-icon-effect: none;
            color: @text;
          }

          #keyboard-state {
            color: @flamingo;
          }

          #workspaces button {
              box-shadow: none;
              text-shadow: none;
              padding: 1px 8px;
              margin: 0 1px;
              border-radius: 6px;
              color: @overlay1;
              background-color: transparent;
              border: 1px solid transparent;
              transition: all 0.2s ease-in-out;
              font-weight: normal;
          }
          
          #workspaces button:first-child {
              margin-left: 3px;
          }
          
          #workspaces button:last-child {
              margin-right: 1px;
          }

          #workspaces button:hover {
              color: @text;
              background-color: @surface1;
              border: none;
          }

          #workspaces button.persistent {
              color: @overlay0;
              background-color: transparent;
          }

          /* Workspaces with windows (occupied) */
          #workspaces button.occupied {
              color: @blue;
              background-color: @surface0;
              border: none;
              font-weight: 500;
          }

          /* Active workspace - clearly distinct */
          #workspaces button.active {
              color: @text;
              background-color: @blue;
              border: none;
              border-radius: 0px;
              font-weight: bold;
              text-shadow: none;
              opacity: 1;
              padding: 1px 8px;
              margin: 0px;
          }

          #workspaces button.urgent {
              color: @theme_base_color;
              background-color: @red;
              border: 1px solid @red;
              animation: urgent-pulse 1s ease-in-out infinite alternate;
          }

          @keyframes urgent-pulse {
              from { 
                  opacity: 1;
              }
              to { 
                  opacity: 0.6;
              }
          }

          #taskbar button.active {
              padding-left: 10px;
              padding-right: 10px;
              animation: gradient_f 20s ease-in infinite;
              transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
          }

          #taskbar button:hover {
              padding-left: 4px;
              padding-right: 4px;
              animation: gradient_f 20s ease-in infinite;
              transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
          }

          #custom-cava_mviz {
          	color: @pink;
          }

          #cava {
          	color: @pink;
            padding-left: 18px;
            padding-bottom: 8px;
            border-bottom: 2px solid transparent;
          }

          #mpris {
          	color: @pink;
          }

          #custom-menu {
            color: @rosewater;
          }

          #custom-power {
            color: @red;
            background-color: transparent;
            border-left: 1px solid @blue;
            padding: 1px 12px 1px 21px;
            margin: 0 1.5px;
            margin-left: 16px;
          }

          #custom-updater {
            color: @red;
          }

          #custom-light_dark {
            color: @blue;
          }

          #custom-weather {
            color: @lavender;
          }

          #custom-lock {
            color: @maroon;
          }

          #pulseaudio {
            color: @lavender;
          }

          #pulseaudio.bluetooth {
            color: @pink;
          }
          #pulseaudio.muted {
            color: @red;
          }

          #window {
            color: @mauve;
          }

          #custom-waybar-mpris {
            color:@lavender;
          }

          #network {
            color: @blue;
          }
          #network.disconnected,
          #network.disabled {
            background-color: @surface0;
            color: @text;
          }
          #pulseaudio-slider slider {
          	min-width: 0px;
          	min-height: 0px;
          	opacity: 0;
          	background-image: none;
          	border: none;
          	box-shadow: none;
          }

          #pulseaudio-slider trough {
          	min-width: 80px;
          	min-height: 5px;
          	border-radius: 5px;
          }

          #pulseaudio-slider highlight {
          	min-height: 10px;
          	border-radius: 5px;
          }

          #backlight-slider slider {
          	min-width: 0px;
          	min-height: 0px;
          	opacity: 0;
          	background-image: none;
          	border: none;
          	box-shadow: none;
          }

          #backlight-slider trough {
          	min-width: 80px;
          	min-height: 10px;
          	border-radius: 5px;
          }

          #backlight-slider highlight {
          	min-width: 10px;
          	border-radius: 5px;
          }

        '';
      };
    })
  ];
}