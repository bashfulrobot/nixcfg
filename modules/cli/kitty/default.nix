{ user-settings, config, pkgs, lib, ... }:
let 
  cfg = config.cli.kitty;
  inherit (config.lib.stylix) colors;
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
            hide_window_decorations = "yes";
            editor = "${pkgs.unstable.helix}/bin/hx";
            cursor_shape = "block";
            macos_titlebar_color = "background";
            clipboard_max_size = 0;
            window_padding_width = 15;
            bold_font = "auto";
            italic_font = "auto";
            bold_italic_font = "auto";
            
            # Stylix color integration
            foreground = lib.mkIf (config.stylix.enable or false) "#${colors.base05}";
            background = lib.mkIf (config.stylix.enable or false) "#${colors.base00}";
            selection_foreground = lib.mkIf (config.stylix.enable or false) "#${colors.base00}";
            selection_background = lib.mkIf (config.stylix.enable or false) "#${colors.base05}";
            cursor = lib.mkIf (config.stylix.enable or false) "#${colors.base05}";
            cursor_text_color = lib.mkIf (config.stylix.enable or false) "#${colors.base00}";
            
            # Terminal colors (base16)
            color0 = lib.mkIf (config.stylix.enable or false) "#${colors.base00}";
            color1 = lib.mkIf (config.stylix.enable or false) "#${colors.base08}";
            color2 = lib.mkIf (config.stylix.enable or false) "#${colors.base0B}";
            color3 = lib.mkIf (config.stylix.enable or false) "#${colors.base0A}";
            color4 = lib.mkIf (config.stylix.enable or false) "#${colors.base0D}";
            color5 = lib.mkIf (config.stylix.enable or false) "#${colors.base0E}";
            color6 = lib.mkIf (config.stylix.enable or false) "#${colors.base0C}";
            color7 = lib.mkIf (config.stylix.enable or false) "#${colors.base05}";
            color8 = lib.mkIf (config.stylix.enable or false) "#${colors.base03}";
            color9 = lib.mkIf (config.stylix.enable or false) "#${colors.base08}";
            color10 = lib.mkIf (config.stylix.enable or false) "#${colors.base0B}";
            color11 = lib.mkIf (config.stylix.enable or false) "#${colors.base0A}";
            color12 = lib.mkIf (config.stylix.enable or false) "#${colors.base0D}";
            color13 = lib.mkIf (config.stylix.enable or false) "#${colors.base0E}";
            color14 = lib.mkIf (config.stylix.enable or false) "#${colors.base0C}";
            color15 = lib.mkIf (config.stylix.enable or false) "#${colors.base07}";
          };
          environment = {
            # Set the default shell to fish
            SHELL = "${pkgs.fish}/bin/fish";
            COLORTERM = "truecolor";
            WINIT_X11_SCALE_FACTOR = "1";
            EDITOR = "${pkgs.unstable.helix}/bin/hx";
          };
          font = {
            name = lib.mkForce "Victor Mono";
            size = lib.mkForce 18;
          };
        }
      ];
    };
  };
}
