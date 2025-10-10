{
  lib,
  config,
  ...
}:
{
  home-manager.sharedModules = lib.mkIf (config.desktops.tiling.hyprland.enable or false) [
    (_: {
      services.swaync = {
        enable = true;
        settings = {
          "$schema" = "/etc/xdg/swaync/configSchema.json";

          # Position settings - notifications center, control center right
          positionX = "center";
          positionY = "top";
          control-center-positionX = "none";
          control-center-positionY = "none";

          # Control center settings
          control-center-margin-top = 8;
          control-center-margin-bottom = 8;
          control-center-margin-right = 8;
          control-center-margin-left = 8;
          control-center-width = 500;
          control-center-height = -1;

          # Layer and behavior
          fit-to-screen = false;
          layer-shell-cover-screen = false;
          layer = "top";
          cssPriority = "user";

          # Notification settings
          notification-2fa-command = true;
          notification-inline-replies = true;
          notification-icon-size = 64;
          notification-body-image-height = 100;
          notification-body-image-width = 200;
          notification-window-width = 400;

          # Timeout settings
          timeout = 5;
          timeout-low = 3;
          timeout-critical = 0;

          # Behavior settings
          keyboard-shortcuts = true;
          image-visibility = "always";
          transition-time = 200;
          hide-on-clear = true;
          hide-on-action = true;
          script-fail-notify = true;

          # Widgets (from ErikReider's config)
          widgets = [
            "inhibitors"
            "title"
            "dnd"
            "mpris"
            "volume"
            "backlight"
            "menubar"
            "notifications"
          ];

          widget-config = {
            inhibitors = {
              text = "Inhibitors";
              button-text = "";
              clear-all-button = true;
            };
            title = {
              text = "Notifications";
              clear-all-button = true;
              button-text = "󰩺";
            };
            dnd = {
              text = "Do Not Disturb";
            };
            label = {
              max-lines = 5;
              text = "Label Text";
            };
            mpris = {
              image-size = 96;
              image-radius = 4;
              autohide = true;
              blacklist = ["playerctld"];
            };
            volume = {
              label = "󰕾";
              show-per-app = true;
            };
            backlight = {
              label = "󰃟";
              device = "intel_backlight";
            };
            menubar = {
              "menu#power-buttons" = {
                label = "⏻";
                position = "right";
                actions = [
                  {
                    label = "Reboot";
                    command = "systemctl reboot";
                  }
                  {
                    label = "Shutdown";
                    command = "systemctl poweroff";
                  }
                ];
              };
            };
          };
        };

        style = ''
          /* Custom styling additions to Stylix base */

          /* Control center background - use solid color */
          .control-center {
            background: @noti-bg !important;
            background-color: @noti-bg !important;
          }

          /* Remove fade out effect at bottom */
          .control-center .notification-row:last-child {
            background: none !important;
          }

          .control-center::after {
            display: none !important;
          }

          /* Widget styling */
          .widget-title > button {
            border-radius: 12px;
          }

          .widget-dnd > switch {
            border-radius: 12px;
          }

          .widget-mpris-player {
            border-radius: 12px;
          }

          .widget-volume {
            border-radius: 12px;
          }

          .widget-backlight {
            border-radius: 12px;
          }

          .widget-menubar {
            border-radius: 12px;
          }
        '';
      };
    })
  ];
}