{ user-settings, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    services.swaync = {
      enable = true;
    };

    xdg.configFile."swaync/config.json".text = ''
      {
        "positionX": "right",
        "positionY": "top",
        "layer": "overlay",
        "control-center-margin-top": 0,
        "control-center-margin-bottom": 0,
        "control-center-margin-right": 0,
        "control-center-margin-left": 0,
        "notification-2fa-action": true,
        "notification-inline-replies": false,
        "notification-icon-size": 64,
        "notification-body-image-height": 100,
        "notification-body-image-width": 200,
        "timeout": 10,
        "timeout-low": 5,
        "timeout-critical": 0,
        "fit-to-screen": true,
        "control-center-width": 500,
        "control-center-height": 600,
        "notification-window-width": 500,
        "keyboard-shortcuts": true,
        "image-visibility": "when-available",
        "transition-time": 200,
        "hide-on-clear": false,
        "hide-on-action": true,
        "script-fail-notify": true,
        "scripts": {
          "example-script": {
            "exec": "echo 'Do something...'",
            "urgency": "Normal"
          }
        },
        "notification-visibility": {
          "example-name": {
            "state": "muted",
            "urgency": "Low",
            "app-name": "Spotify"
          }
        },
        "widgets": [
          "title",
          "buttons-grid",
          "mpris",
          "volume",
          "backlight",
          "dnd",
          "notifications"
        ],
        "widget-config": {
          "title": {
            "text": "Notification Center",
            "clear-all-button": true,
            "button-text": "Clear All"
          },
          "dnd": {
            "text": "Do Not Disturb"
          },
          "label": {
            "max-lines": 5,
            "text": "Label Text"
          },
          "mpris": {
            "image-size": 96,
            "image-radius": 12
          },
          "volume": {
            "expand-button-label": "⏷",
            "collapse-button-label": "⏶",
            "show-per-app": true
          },
          "backlight": {
            "device": "intel_backlight",
            "subsystem": "backlight"
          },
          "buttons-grid": {
            "actions": [
              {
                "label": "⚡",
                "command": "systemctl poweroff"
              },
              {
                "label": "🔃",
                "command": "systemctl reboot"
              },
              {
                "label": "🔒",
                "command": "swaylock"
              },
              {
                "label": "🚪",
                "command": "niri msg logout"
              },
              {
                "label": "⏸️",
                "command": "systemctl suspend"
              }
            ]
          }
        }
      }
    '';
  };
}
