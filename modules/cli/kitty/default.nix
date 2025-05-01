{ user-settings, config, pkgs, lib, ... }:
let cfg = config.cli.kitty;

in {

  options = {
    cli.kitty.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kitty terminal.";
    };
  };

  config = lib.mkIf cfg.enable {

    ### HOME MANAGER SETTINGS
    home-manager.users."${user-settings.user.username}" = {

      programs.kitty = {
        enable = true;
        package = pkgs.unstable.kitty;
        shellIntegration = {
          enableFishIntegration = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
        };
        environment = {
          # Set the default shell to fish
          SHELL = "${pkgs.fish}/bin/fish";
          COLORTERM = "truecolor";
          WINIT_X11_SCALE_FACTOR = "1";
          EDITOR = "${pkgs.unstable.helix}/bin/hx";
        };
        font = {
          name = "Victor Mono";
          size = 14;
        };

      };
    };

    # Install kitty via Homebrew when on Darwin
    # homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [
    #   "wezterm"
    # ];
  };
}
