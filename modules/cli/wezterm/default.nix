{ user-settings, config, pkgs, lib, ... }:
let cfg = config.cli.wezterm;

in {

  options = {
    cli.wezterm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Wezterm terminal.";
    };
  };

  config = lib.mkIf cfg.enable {

    ### HOME MANAGER SETTINGS
    home-manager.users."${user-settings.user.username}" = {

      # home.packages = with pkgs; [ mimeo ];

      programs.wezterm = {
        enable = true;
        extraConfig = ''
          local wezterm = require 'wezterm'

          return {
            font = wezterm.font_with_fallback({
              "Victor Mono",
              "Font Awesome 6 Free",
              "Font Awesome 6 Free Regular",
              "Font Awesome 6 Free Solid",
              "Font Awesome 6 Brands",
            }),
            font_size = 20,
          }
        '';
      };
    };

    # Install wezterm via Homebrew when on Darwin
    homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [
      "wezterm"
    ];
  };
}
