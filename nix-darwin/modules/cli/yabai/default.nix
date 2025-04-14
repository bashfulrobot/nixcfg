{ user-settings, config, lib, pkgs, ... }:
let
  cfg = config.cli.yabai;
  yabai = "${pkgs.yabai}/bin/yabai";
  jq = "${pkgs.jq}/bin/jq";
in {
  options = {
    cli.yabai.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable yabai tiling manager.";
    };
  };

  config = lib.mkIf cfg.enable {

    # homebrew = {
    #   taps = [ "sylvanfranklin/srhd" ];
    #   brews = [ "sylvanfranklin/srhd/srhd" ];
    # };

    # Add srhd to launch at login
    # launchd.user.agents.srhd = {
    #   path = [ cfg.package ];
    #   command = "${cfg.package}/bin/ollama serve";
    #   environment = { OLLAMA_HOST = "${cfg.hostname}:${toString cfg.port}"; };
    #   serviceConfig = {
    #     KeepAlive = true;
    #     RunAtLoad = true;
    #     ProcessType = "Background";
    #   };
    # };

    services = {
      yabai = {
        enable = true;
        enableScriptingAddition = true;
        package = pkgs.unstable.yabai;
        config = {
          focus_follows_mouse = "off";
          mouse_follows_focus = "off";
          auto_balance = "on";
          layout = "bsp";
          top_padding = 10;
          bottom_padding = 10;
          left_padding = 10;
          right_padding = 10;
          window_gap = 10;
          mouse_action1 = "move";
          mouse_action2 = "resize";
          mouse_drop_action = "swap";
          mouse_modifier = "alt";
          window_opacity = "on";
          window_opacity_duration = "0.0";
          active_window_opacity = "1.0";
          normal_window_opacity = "0.8";
          window_topmost =
            "off"; # Disabled because browser popups will disappear if its enabled
          window_shadow = "float";
          window_placement = "second_child";
        };
        extraConfig = ''
          yabai -m rule --add app="^(Calculator|Software Update|Dictionary|VLC|System Preferences|System Settings|Photo Booth|Archive Utility|App Store|Activity Monitor)$" manage=off
          yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
          yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
          yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
          yabai -m rule --add label="Select file to save to" app="^Inkscape$" title="Select file to save to" manage=off
        '';
      };

      # skhd = {
      #   enable = true;
      #   package = pkgs.unstable.skhd;
      # };
    };

    # environment.etc."skhdrc" = {
    #   text = ''
    #     # NOTE: First five are handled by MacOS
    #     ctrl - 6                : yabai -m space --focus 6
    #     ctrl - 7                : yabai -m space --focus 7
    #     ctrl - 8                : yabai -m space --focus 8
    #     ctrl - 9                : yabai -m space --focus 9
    #     ctrl - 0                : yabai -m space --focus 10

    #     ctrl + shift - 1        : yabai -m window --space 1
    #     ctrl + shift - 2        : yabai -m window --space 2
    #     ctrl + shift - 3        : yabai -m window --space 3
    #     ctrl + shift - 4        : yabai -m window --space 4
    #     ctrl + shift - 5        : yabai -m window --space 5
    #     ctrl + shift - 6        : yabai -m window --space 6
    #     ctrl + shift - 7        : yabai -m window --space 7
    #     ctrl + shift - 8        : yabai -m window --space 8
    #     ctrl + shift - 9        : yabai -m window --space 9
    #     ctrl + shift - 0        : yabai -m window --space 10

    #     cmd + ctrl - g          : yabai -m window --toggle float
    #     cmd + ctrl - e          : yabai -m window --toggle split
    #     cmd + ctrl - w          : yabai -m window --toggle zoom-fullscreen

    #     cmd + ctrl - h          : yabai -m window --focus west
    #     cmd + ctrl - j          : yabai -m window --focus south
    #     cmd + ctrl - k          : yabai -m window --focus north
    #     cmd + ctrl - l          : yabai -m window --focus east

    #     cmd + ctrl + shift - h  : yabai -m window --warp west
    #     cmd + ctrl + shift - j  : yabai -m window --warp south
    #     cmd + ctrl + shift - k  : yabai -m window --warp north
    #     cmd + ctrl + shift - l  : yabai -m window --warp east

    #     alt - return            : /opt/homebrew/bin/ghostty
    #     # cmd + shift - o       : /Applications/firefox.app/Contents/MacOS/firefox
    #     #
    #   '';
    # };

    home-manager.users."${user-settings.user.username}" = {

    };

  };

}
