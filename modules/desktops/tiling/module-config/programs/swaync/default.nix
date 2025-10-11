{ config, lib, pkgs, ... }:

let
  buildTheme = pkgs.callPackage ../../../../../../lib/stylix-theme.nix { };
  style = buildTheme.build {
    inherit (config.lib.stylix) colors;
    inherit (config.stylix) fonts;
    file = builtins.readFile ./style.css;
  };
in
{
  home-manager.sharedModules = lib.mkIf (config.desktops.tiling.hyprland.enable or false) [
    (_: {
      services.swaync = {
        enable = true;
        inherit style;
        settings = {
          "$schema" = "/etc/xdg/swaync/configSchema.json";

          # Position settings - notifications and control center on right
          positionX = "right";
          positionY = "top";
          layer = "overlay";
          layer-shell = true;
          cssPriority = "user";

          # Control center settings (from reference)
          control-center-width = 380;
          control-center-height = 860;
          control-center-margin-top = 8;
          control-center-margin-bottom = 8;
          control-center-margin-right = 8;
          control-center-margin-left = 8;

          # Notification settings (from reference)
          notification-window-width = 400;
          notification-icon-size = 48;
          notification-body-image-height = 160;
          notification-body-image-width = 200;

          # Widgets (based on reference but keeping useful elements from current)
          widgets = [
            "buttons-grid"
            "title"
            "dnd"
            "notifications"
            "mpris"
          ];

          widget-config = {
            title = {
              text = "Notifications";
              clear-all-button = true;
              button-text = "Clear All";
            };
            dnd = {
              text = "Do Not Disturb";
            };
            label = {
              max-lines = 1;
              text = " ";
            };
            mpris = {
              image-size = 60;
              image-radius = 12;
            };
            buttons-grid = {
              actions = [
                {
                  label = "󰂯";
                  command = "blueman-manager &";
                }
                {
                  label = "󰤨";
                  command = "nm-connection-editor";
                }
                {
                  label = "󰕾";
                  command = "pwvucontrol";
                }
                {
                  label = "⏻";
                  command = "wlogout -b 4";
                }
              ];
            };
          };
        };
      };
    })
  ];
}