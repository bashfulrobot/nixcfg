{
  user-settings,
  config,
  lib,
  ...
}:

{
  # COSMIC Terminal Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # COSMIC Terminal configurations
      "cosmic/com.system76.CosmicTerm/v1/font_name" = {
        text = ''
          "JetBrainsMono Nerd Font Mono"
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicTerm/v1/font_size" = {
        text = ''
          18
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicTerm/v1/use_bright_bold" = {
        text = ''
          true
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicTerm/v1/show_headerbar" = {
        text = ''
          false
        '';
        force = true;
      };
    };
  };
}