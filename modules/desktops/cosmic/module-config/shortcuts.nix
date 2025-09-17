{
  user-settings,
  config,
  lib,
  ...
}:

{
  # COSMIC Shortcuts Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # Custom shortcuts configuration for COSMIC Settings
      "cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom" = {
        text = ''
          {
              (
                  modifiers: [
                      Ctrl,
                      Alt,
                  ],
                  key: "p",
              ): System(Screenshot),
          }
        '';
        force = true;
      };
    };
  };
}