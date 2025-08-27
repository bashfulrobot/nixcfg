{ user-settings, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        control-center-width = 380;
        control-center-height = 600;
        notification-window-width = 400;
        keyboard-shortcuts = true;
        image-visibility = "when-available";
        transition-time = 200;
        hide-on-clear = false;
        hide-on-action = false;
        script-fail-notify = true;
        scripts = {};
        notification-visibility = {
          example-name = {
            state = "muted";
            urgency = "Low";
            app-name = "Spotify";
          };
        };
        widgets = [
          "inhibitors"
          "title"
          "dnd"
          "notifications"
        ];
        widget-config = {
          inhibitors = {
            text = "Inhibitors";
            button-text = "Clear All";
            clear-all-button = true;
          };
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear All";
          };
          dnd = {
            text = "Do Not Disturb";
          };
          notifications = {
            clear-all-button = true;
            button-text = "Clear All";
          };
        };
      };
    };
  };
}