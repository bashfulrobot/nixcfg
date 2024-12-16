{ user-settings, config, pkgs, lib, ... }:
let cfg = config.cli.alacritty;

in {

  options = {
    cli.alacritty.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
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
            normal = {
              family = "JetBrainsMono Nerd Font Mono";
              style = "Regular";
            };
            size = 20;
            # small y offsetting as iosevka-t184256 has custom -25% line spacing
            offset = {
              x = -2;
              y = -2;
            };
            glyph_offset = {
              x = -1;
              y = -1;
            };
          };

          colors = {
            primary = {
              background = "0x1f1f1f";
              foreground = "0xffffff";
            };
            normal = {
              black = "0x1f1f1f";
              red = "0xe06c75";
              green = "0x98c379";
              yellow = "0xc88800";
              blue = "0x61afef";
              magenta = "0xc678dd";
              cyan = "0x2190a4";
              white = "0xabb2bf";
            };
            bright = {
              black = "0xa9a9a9";
              red = "0xe06c75";
              green = "0x98c379";
              yellow = "0xc88800";
              blue = "0x61afef";
              magenta = "0xc678dd";
              cyan = "0x2190a4";
              white = "0xffffff";
            };
            cursor = {
              text = "0x1f1f1f";
              cursor = "0x6f8396";
            };
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
