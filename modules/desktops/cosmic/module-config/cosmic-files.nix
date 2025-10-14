{
  user-settings,
  config,
  lib,
  ...
}:

{
  # COSMIC Files (File Manager) Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # COSMIC Files configurations
      "cosmic/com.system76.CosmicFiles/v1/tab" = {
        text = ''
          (
              folders_first: true,
              icon_sizes: (
                  list: 100,
                  grid: 100,
              ),
              show_hidden: false,
              single_click: false,
              view: List,
          )
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicFiles/v1/show_details" = {
        text = ''
          false
        '';
        force = true;
      };
    };
  };
}