{
  user-settings,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.cli.wezterm;
  inherit (config.lib.stylix) colors;
in
{

  options = {
    cli.wezterm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Wezterm terminal.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Configure nautilus to use wezterm when enabled  
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "wezterm";
    };

    ### HOME MANAGER SETTINGS
    home-manager.users."${user-settings.user.username}" = {

      programs.wezterm = {
        enable = true;
        package = pkgs.wezterm;
        

        extraConfig = ''
          local wezterm = require 'wezterm'
          local config = {}

          -- Use config builder object if possible
          if wezterm.config_builder then
            config = wezterm.config_builder()
          end

          config.audible_bell = "Disabled"
          config.default_cursor_style = "BlinkingBlock"
          config.default_prog = { '${pkgs.fish}/bin/fish', '-l' }
          config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Regular" })
          config.font_size = 18.0
          config.window_decorations = "INTEGRATED_BUTTONS"
          config.window_padding = {
            left = 15,
            right = 15,
            top = 15,
            bottom = 15,
          }
          

          return config
        '';
      };
    };
  };
}