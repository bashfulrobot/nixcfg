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

      programs.kitty = lib.mkMerge [
        {
          enable = true;
          # https://github.com/kovidgoyal/kitty-themes/tree/master/themes
          # themeFile is the name of the .conf file without the .conf
          package = pkgs.unstable.kitty;
          shellIntegration = {
            enableFishIntegration = true;
            enableZshIntegration = true;
            enableBashIntegration = true;
          };
          settings = {
            confirm_os_window_close = "0";
            editor = "${pkgs.unstable.helix}/bin/hx";
            cursor_shape = "block";
            macos_titlebar_color = "background";
            clipboard_max_size = 0;
            window_padding_width = 15;
            bold_font = "auto";
            italic_font = "auto";
            bold_italic_font = "auto";
          };
          environment = {
            # Set the default shell to fish
            SHELL = "${pkgs.fish}/bin/fish";
            COLORTERM = "truecolor";
            WINIT_X11_SCALE_FACTOR = "1";
            EDITOR = "${pkgs.unstable.helix}/bin/hx";
          };
          font = {
            name = "VictorMono Nerd Font Mono";
            size = 18;
          };
        }
        (lib.mkIf pkgs.stdenv.isDarwin { themeFile = "OneDark"; })
      ];
    };
  };
}
