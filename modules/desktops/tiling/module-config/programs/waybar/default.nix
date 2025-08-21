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
            height = 32; # 35
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
              on-click-right = "bash -c 'selected=$(printf \"🔧 Open PipeWire Control\\n🔇 Toggle Output Mute\\n🎤 Toggle Input Mute\" | rofi -dmenu -p \"Audio Options\" -theme-str \"window {width: 300px;}\"); case \"$selected\" in \"🔧 Open PipeWire Control\") pwvucontrol & ;; \"🔇 Toggle Output Mute\") pamixer -t; notify-send \"🔊 Audio\" \"Output mute toggled\" -t 2000 ;; \"🎤 Toggle Input Mute\") pamixer --default-source -t; notify-send \"🎤 Audio\" \"Input mute toggled\" -t 2000 ;; esac'";
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
              icon-size = 16;
              spacing = 10;
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
            font-size: 14px;
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
          	padding-top: 4px;
          	padding-bottom: 4px;
          	padding-right: 8px;
          	padding-left: 8px;
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

          #tray > .passive {
            -gtk-icon-effect: dim;
          }
          #tray > .needs-attention {
            -gtk-icon-effect: highlight;
          }

          #keyboard-state {
            color: @flamingo;
          }

          #workspaces button {
              box-shadow: none;
          	text-shadow: none;
              padding: 0px;
              border-radius: 9px;
              padding-left: 6px;
              padding-right: 6px;
              animation: gradient_f 20s ease-in infinite;
              transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.682);
          }

          #workspaces button:hover {
          	border-radius: 10px;
          	color: @overlay0;
          	background-color: @surface0;
           	padding-left: 4px;
              padding-right: 4px;
              animation: gradient_f 20s ease-in infinite;
              transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
          }

          #workspaces button.persistent {
          	color: @surface1;
          	border-radius: 10px;
          }

          /* Workspaces with windows (occupied) */
          #workspaces button.occupied {
          	color: @peach;
          	border-radius: 10px;
              padding-left: 8px;
              padding-right: 8px;
              transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
          }

          /* Active workspace - same color as occupied but with straight underline */
          #workspaces button.active {
          	color: @peach;
            	border-radius: 10px 10px 0px 0px;
              padding-left: 10px;
              padding-right: 10px;
              border-bottom: 2px solid @peach;
              animation: gradient_f 20s ease-in infinite;
              transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
          }

          #workspaces button.urgent {
          	color: @red;
           	border-radius: 0px;
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
            padding: 4px 10px;
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