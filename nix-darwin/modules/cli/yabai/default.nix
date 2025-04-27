{ user-settings, config, lib, pkgs, ... }:
let cfg = config.cli.yabai;
in {
  options = {
    cli.yabai.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable yabai tiling manager.";
    };
  };

  config = lib.mkIf cfg.enable {
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
          normal_window_opacity = "1.0";
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
    };

    home-manager.users."${user-settings.user.username}" = {

    };

  };

}
