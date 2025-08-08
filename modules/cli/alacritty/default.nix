{ user-settings, config, pkgs, lib, ... }:
let cfg = config.cli.alacritty;

in {

  options = {
    cli.alacritty.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Alacritty terminal.";
    };
  };

  config = lib.mkIf cfg.enable {

    ### HOME MANAGER SETTINGS
    home-manager.users."${user-settings.user.username}" = {

      home.packages = with pkgs; [ mimeo ];

      programs.alacritty = {
        enable = true;
        settings = {

          # Enable true color support
          env.TERM = "alacritty";
          # env.TERM = "xterm-256color";

          # Fix for: https://github.com/alacritty/alacritty/issues/6703
          env.XCURSOR_THEME = "Adwaita alacritty";

          # shell.program = "tmux";

          selection.save_to_clipboard = true;

          font = {
            # Preserve font offset settings for VictorMono (commented out to match Kitty)
            # offset = {
            #   x = 2;
            #   y = 1;
            # };
            # glyph_offset = {
            #   x = 6;
            #   y = 1;
            # };
            normal = {
              family = "JetBrainsMono Nerd Font Mono";
              style = "Regular";
            };
            size = lib.mkDefault 18;
          };

          # dynamic_title = true;

          scrolling = {
            history = 10000;
            multiplier = 3;
          };

          bell = {
            animation = "EaseOutQuart";
            duration = 100;
            # color = "0x1d2021";
          };

          cursor = {
            style = "Block";
            unfocused_hollow = true;
          };

          # Colours specified in the theme folder

          window = {
            # decorations = "full";
            # decorations = "none";
            decorations = "Buttonless";
            # startup_mode = "Windowed";
            # set in stylix
            # opacity = 0.96;
            dynamic_padding = true;
            padding = {
              x = 30;
              y = 30;
            };
          };
          hints = {
            enabled = [{
              regex = ''
                (mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001F\u007F-\u009F<>"\\s{-}\\^⟨⟩`]+'';
              command = "${pkgs.mimeo}/bin/mimeo";
              post_processing = true;
              mouse.enabled = true;
            }];
          };
          keyboard = {
            bindings = [
              {
                key = "V";
                mods = "Control|Shift";
                action = "Paste";
              }
              {
                key = "C";
                mods = "Control|Shift";
                action = "Copy";
              }
              {
                key = "Up";
                mods = "Control|Shift";
                action = "ScrollPageUp";
              }
              {
                key = "Down";
                mods = "Control|Shift";
                action = "ScrollPageDown";
              }
            ];
          };
        };
      };
    };
  };
}
