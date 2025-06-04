{
  user-settings,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    # Base ironbar
    ironbar

    # Icon theme used by ironbar
    papirus-icon-theme

    # Font requirements
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    # Dependencies for your modules
    wl-clipboard # For clipboard module
    eww # For GitHub widget scripts

    # Music player support (MPRIS)
    playerctl # For music module

    # Notification handling
    libnotify # For notification support
  ];

  # Font configuration
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Ensure D-Bus is running for MPRIS and notifications
  services.dbus.enable = true;
  home-manager.users."${user-settings.user.username}" = {

    home.file = {

      ".config/ironbar/scripts/eww_open.sh" = {
        text = ''
          #!/bin/bash

          if [ $# -eq 0 ]; then
              echo "Usage: $0 widget1 [widget2 ...]"
              exit 1
          fi

          active_windows=$(eww active-windows)

          is_widget_open() {
              echo "$active_windows" | grep -q "^$1:"
          }

          any_widget_open=false
          for widget in "$@"; do
              if is_widget_open "$widget"; then
                  any_widget_open=true
                  break
              fi
          done

          echo "$@"
          if [ "$any_widget_open" = true ]; then
              eww close "$@"
          else
              eww open-many "$@"
          fi
        '';
        executable = true;
      };

      ".config/ironbar/style.css".text = ''
        {{gtk_colors}}

        *:not(#bar) {
            font-family: "VictorMono Nerd Font";
            font-size: 16px;
            margin-left: 3px;
            margin-right: 3px;
            border-radius: 12px;
        }

        .background {
            background-color: transparent;
        }

        #bar {
            margin-top: 2px;
            background-color: transparent;
        }

        button {
            background-color: @base01;
        }

        button,
        label {
            color: @base05;
        }

        button:hover {
            background-color: @base00;
        }

        .popup {
            padding: 1em;
            border: 1px solid @base00;
            background-color: @base01;
        }

        .launcher .item {
            margin-left: 6px;
        }

        .clock label {
            margin-left: 10px;
            margin-right: 10px;
        }

        .clock > button {
            background-color: red;
        }

        .clock {
            font-weight: bold;
        }

        .popup-clock .calendar-clock {
            color: @text;
            font-size: 2.5em;
            margin-bottom: 5px;
            padding-left: 5px;
            padding-right: 5px;
            background-color: @surface0;
        }

        .volume label {
            margin-left: 8px;
            margin-right: 10px;
        }

        .clipboard label {
            margin-left: 8px;
            margin-right: 10px;
        }

        .notifications label {
            margin-left: 8px;
            margin-right: 10px;
        }

        .notifications .count {
            font-size: 0.6rem;
            background-color: @text;
            color: @crust;
            border-radius: 100%;
            margin-right: 3px;
            margin-top: 3px;
            padding-left: 4px;
            padding-right: 4px;
            opacity: 0.7;
        }

        .tray {
            background-color: @base01;
        }

        menu {
            border: 0px;
            background-color: @base01;
        }

        check {
            -gtk-icon-source: none;
            border: 2px solid @base08;
            border-radius: 3px;
            padding: 1px;
            min-height: 12px;
            min-width: 12px;
            transition: all 200ms ease-in;
        }

        checkbutton {
            -gtk-icon-source: none;
            border: none;
            background: none;
        }

        menu menuitem:hover {
            background-color: #{{base0B}};
        }

        menu checkmenuitem:checked check {
            background-color: #4CAF50; /* Green background for checked checkbox */
            border-color: #388E3C; /* Darker green border */
        }

        .popup-volume .device-box .device-selector {
            background-color: @surface0;
        }

        .popup-volume .device-box .slider {
            background-color: @surface0;
        }
      '';

      ".config/ironbar/config.json".text = ''
                {
          "$schema": "https://f.jstanger.dev/github/ironbar/schema.json",
          "anchor_to_edges": true,
          "position": "top",
          "icon_theme": "Papirus",
          "start": [
            {
              "type": "launcher",
              "show_names": false,
              "show_icons": true
            }
          ],
          "center": [
            {
              "type": "clock",
              "disable_popup": true
            }
          ],
          "end": [
            {
              "type": "music",
              "player_type": "mpris",
              "truncate": "start"
            },
            {
              "type": "volume",
              "format": "{icon} {percentage}%",
              "max_volume": 100,
              "icons": {
                "volume_high": "󰕾",
                "volume_medium": "󰖀",
                "volume_low": "󰕿",
                "muted": "󰝟"
              }
            },
            {
              "type": "custom",
              "bar": [
                {
                  "type": "box",
                  "name": "github",
                  "widgets": [
                    {
                      "type": "button",
                      "on_click": "!~/.config/ironbar/scripts/eww_open.sh github_issues github_issues-closer",
                      "tooltip": "GitHub Issues",
                      "widgets": [
                        {
                          "type": "image",
                          "src": "file:///home/okno/.config/eww/icons/gh/issue_icon.svg",
                          "size": 20
                        }
                      ]
                    },
                    {
                      "type": "button",
                      "label": "",
                      "on_click": "!~/.config/ironbar/scripts/eww_open.sh github_prs github_prs-closer",
                      "tooltip": "GitHub PRs",
                      "widgets": [
                        {
                          "type": "image",
                          "src": "file:///home/okno/.config/eww/icons/gh/pr_icon.svg",
                          "size": 20
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "clipboard",
              "max_items": 3,
              "truncate": {
                "mode": "end",
                "length": 50
              }
            },
            {
              "type": "notifications",
              "show_count": true,
              "icons": {
                "closed_none": "",
                "closed_some": "",
                "closed_dnd": "",
                "open_none": "",
                "open_some": "",
                "open_dnd": ""
              }
            },
            {
              "type": "tray",
              "direction": "horizontal",
              "icon_size": 24
            }
          ]
        }

      '';
    };
  };

}
