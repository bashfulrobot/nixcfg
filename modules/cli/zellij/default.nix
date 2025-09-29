{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  ...
}:
let
  cfg = config.cli.zellij;
in
{
  options = {
    cli.zellij.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable zellij.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ wl-clipboard ];
    # TODO: Update version periodically

    home-manager.users."${user-settings.user.username}" = {

      programs.zellij = {
        enable = true;
        enableBashIntegration = false;
        enableFishIntegration = false;
        settings = {
          scrollback_editor = "hx";
          copy_on_select = true;
          copy_command = "wl-copy";
          copy_clipboard = "system";
          paste_command = "wl-paste";
          default_shell = lib.getExe pkgs.fish;
          scroll_buffer_size = 50000;
          mouse_mode = false;
          default_mode = "normal";
          show_startup_tips = false;
          default_layout = "compact";
          pane_frames = false;
          ui = {
            pane_frames.hide_session_name = true;
          };

          layouts = {
            compact = {
              tab_template = {
                children = [
                  {
                    pane = { };
                  }
                ];
                pane = {
                  borderless = true;
                };
              };
              pane_template = {
                children = [
                  {
                    pane = { };
                  }
                ];
                pane = {
                  borderless = true;
                };
              };
            };
          };

          plugins = {
            compact-bar = {
              location = "zellij:compact-bar";
              tooltip = "F1";
            };
          };

          # TODO: Until I can figure out: https://github.com/karimould/zellij-forgot/issues/11
          # keybinds = {
          #   "shared_except \"locked\"" = {
          #     "bind \"Ctrl y\"" = {
          #       LaunchOrFocusPlugin = [
          #         "file:~/.config/zellij/plugins/zellij_forgot.wasm"
          #       ];
          #     };
          #   };

          # };

        };
      };
      home.file = {

        # ".config/zellij/plugins/zellij_forgot.wasm".source = pkgs.fetchurl {
        #   url =
        #     "https://github.com/karimould/zellij-forgot/releases/download/0.4.1/zellij_forgot.wasm";
        #   sha256 = "1pxwy5ld3affpzf20i1zvn3am12vs6jwp06wbshw4g1xw8drj4ch";
        # };
        # ".config/zellij/keybindings.kdl".text = ''
        #   keybinds {
        #       shared_except {
        #           locked {
        #               bind {
        #                   "Ctrl y" {
        #                       LaunchOrFocusPlugin {
        #                           plugin = "file:~/zellij-plugins/zellij_forgot.wasm"
        #                           lock = "ctrl + g"
        #                           unlock = "ctrl + g"
        #                           "new pane" = "ctrl + p + n"
        #                           "change focus of pane" = "ctrl + p + arrow key"
        #                           "close pane" = "ctrl + p + x"
        #                           "rename pane" = "ctrl + p + c"
        #                           "toggle fullscreen" = "ctrl + p + f"
        #                           "toggle floating pane" = "ctrl + p + w"
        #                           "toggle embed pane" = "ctrl + p + e"
        #                           "choose right pane" = "ctrl + p + l"
        #                           "choose left pane" = "ctrl + p + r"
        #                           "choose upper pane" = "ctrl + p + k"
        #                           "choose lower pane" = "ctrl + p + j"
        #                           "new tab" = "ctrl + t + n"
        #                           "close tab" = "ctrl + t + x"
        #                           "change focus of tab" = "ctrl + t + arrow key"
        #                           "rename tab" = "ctrl + t + r"
        #                           "sync tab" = "ctrl + t + s"
        #                           "brake pane to new tab" = "ctrl + t + b"
        #                           "brake pane left" = "ctrl + t + ["
        #                           "brake pane right" = "ctrl + t + ]"
        #                           "toggle tab" = "ctrl + t + tab"
        #                           "increase pane size" = "ctrl + n + +"
        #                           "decrease pane size" = "ctrl + n + -"
        #                           "increase pane top" = "ctrl + n + k"
        #                           "increase pane right" = "ctrl + n + l"
        #                           "increase pane bottom" = "ctrl + n + j"
        #                           "increase pane left" = "ctrl + n + h"
        #                           "decrease pane top" = "ctrl + n + K"
        #                           "decrease pane right" = "ctrl + n + L"
        #                           "decrease pane bottom" = "ctrl + n + J"
        #                           "decrease pane left" = "ctrl + n + H"
        #                           "move pane to top" = "ctrl + h + k"
        #                           "move pane to right" = "ctrl + h + l"
        #                           "move pane to bottom" = "ctrl + h + j"
        #                           "move pane to left" = "ctrl + h + h"
        #                           search = "ctrl + s + s"
        #                           "go into edit mode" = "ctrl + s + e"
        #                           "detach session" = "ctrl + o + w"
        #                           "open session manager" = "ctrl + o + w"
        #                           "quit zellij" = "ctrl + q"
        #                           floating = true
        #                           "LOAD_ZELLIJ_BINDINGS" "false"
        #                       }
        #                   }
        #               }
        #           }
        #       }
        #   }
        # '';
      };
    };
  };
}
