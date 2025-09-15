{
  user-settings,
  config,
  lib,
  ...
}:
{
  # COSMIC Application-Specific Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # COSMIC Terminal configurations
      "cosmic/com.system76.CosmicTerm/v1/font_name".text = ''
        "JetBrainsMono Nerd Font Mono"
      '';

      "cosmic/com.system76.CosmicTerm/v1/font_size".text = ''
        18
      '';

      "cosmic/com.system76.CosmicTerm/v1/use_bright_bold".text = ''
        true
      '';

      # COSMIC Edit configurations
      "cosmic/com.system76.CosmicEdit/v1/word_wrap".text = ''
        true
      '';

      "cosmic/com.system76.CosmicEdit/v1/line_numbers".text = ''
        true
      '';

      "cosmic/com.system76.CosmicEdit/v1/highlight_current_line".text = ''
        true
      '';

      "cosmic/com.system76.CosmicEdit/v1/font_name".text = ''
        "JetBrainsMonoNL Nerd Font Mono"
      '';

      "cosmic/com.system76.CosmicEdit/v1/font_size".text = ''
        18
      '';

      "cosmic/com.system76.CosmicEdit/v1/vim_bindings".text = ''
        true
      '';
    };
  };
}