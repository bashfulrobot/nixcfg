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
      description = "Enable Yabai tiling manager.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment = {
      etc."sudoers.d/yabai" = {
        text =
          "dustin.krysak ALL = (root) NOPASSWD: /opt/homebrew/bin/yabai --load-sa";
      };

    };

    services = {
      skhd = {
        enable = true;
        skhdConfig = builtins.readFile ./skhd;
      };
      yabai = {
        enable = true;
        enableScriptingAddition = true;
        config = {
          focus_follows_mouse = "off";
          mouse_follows_focus = "off";
          # external_bar = "all:24:0";
          window_placement = "second_child";
          window_opacity = "on";
          window_opacity_duration = "0.0";
          window_border = "on";
          window_border_placement = "inset";
          window_border_width = 2;
          window_border_radius = 3;
          active_window_border_topmost = "off";
          window_topmost = "on";
          window_shadow = "float";
          active_window_border_color = "0xff5c7e81";
          normal_window_border_color = "0xff505050";
          insert_window_border_color = "0xffd75f5f";
          active_window_opacity = "1.0";
          normal_window_opacity = "0.8";
          split_ratio = "0.50";
          auto_balance = "on";
          mouse_modifier = "fn";
          mouse_action1 = "move";
          mouse_action2 = "resize";
          layout = "bsp";
          top_padding = 10;
          bottom_padding = 10;
          left_padding = 10;
          right_padding = 10;
          window_gap = 10;
        };
      };
    };

    # home-manager.users."${user-settings.user.username}" = {

    #   home.file.".config/yabai/yabairc".text = ''
    #     # for this to work you must configure sudo such that
    #     # it will be able to run the command without password
    #     yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
    #     sudo yabai --load-sa

    #     # default layout (can be bsp, stack or float)
    #     yabai -m config layout bsp

    #     # New window spawns to the right if vertical split, or bottom if horizontal split
    #     yabai -m config window_placement second_child

    #     # padding set to 12px
    #     yabai -m config top_padding 12
    #     yabai -m config bottom_padding 12
    #     yabai -m config left_padding 12
    #     yabai -m config right_padding 12
    #     yabai -m config window_gap 12

    #     # center mouse on window with focus
    #     yabai -m config mouse_follows_focus on

    #     # modifier for clicking and dragging with mouse
    #     yabai -m config mouse_modifier alt
    #     # set modifier + left-click drag to move window
    #     yabai -m config mouse_action1 move
    #     # set modifier + right-click drag to resize window
    #     yabai -m config mouse_action2 resize

    #     # when window is dropped in center of another window, swap them (on edges it will split it)
    #     yabai -m mouse_drop_action swap

    #     yabai -m rule --add app="^System Settings$" manage=off
    #     yabai -m rule --add app="^Calculator$" manage=off
    #   '';

    #   home.file.".config/skhd/skhdrc".text = ''
    #     # change window focus within space
    #     alt - j : yabai -m window --focus south
    #     alt - k : yabai -m window --focus north
    #     alt - h : yabai -m window --focus west
    #     alt - l : yabai -m window --focus east

    #     #change focus between external displays (left and right)
    #     alt - s: yabai -m display --focus west
    #     alt - g: yabai -m display --focus east

    #     # rotate layout clockwise
    #     shift + alt - r : yabai -m space --rotate 270

    #     # flip along y-axis
    #     shift + alt - y : yabai -m space --mirror y-axis

    #     # flip along x-axis
    #     shift + alt - x : yabai -m space --mirror x-axis

    #     # toggle window float
    #     shift + alt - t : yabai -m window --toggle float --grid 4:4:1:1:2:2

    #     # maximize a window
    #     shift + alt - m : yabai -m window --toggle zoom-fullscreen

    #     # balance out tree of windows (resize to occupy same area)
    #     shift + alt - e : yabai -m space --balance

    #     # swap windows
    #     shift + alt - j : yabai -m window --swap south
    #     shift + alt - k : yabai -m window --swap north
    #     shift + alt - h : yabai -m window --swap west
    #     shift + alt - l : yabai -m window --swap east

    #     # move window and split
    #     ctrl + alt - j : yabai -m window --warp south
    #     ctrl + alt - k : yabai -m window --warp north
    #     ctrl + alt - h : yabai -m window --warp west
    #     ctrl + alt - l : yabai -m window --warp east

    #     # move window to display left and right
    #     shift + alt - s : yabai -m window --display west; yabai -m display --focus west;
    #     shift + alt - g : yabai -m window --display east; yabai -m display --focus east;

    #     #move window to prev and next space
    #     shift + alt - p : yabai -m window --space prev;
    #     shift + alt - n : yabai -m window --space next;

    #     # move window to space #
    #     shift + alt - 1 : yabai -m window --space 1;
    #     shift + alt - 2 : yabai -m window --space 2;
    #     shift + alt - 3 : yabai -m window --space 3;
    #     shift + alt - 4 : yabai -m window --space 4;
    #     shift + alt - 5 : yabai -m window --space 5;
    #     shift + alt - 6 : yabai -m window --space 6;
    #     shift + alt - 7 : yabai -m window --space 7;

    #     # stop/start/restart yabai
    #     ctrl + alt - q : yabai --stop-service
    #     ctrl + alt - s : yabai --start-service
    #     ctrl + alt - r : yabai --restart-service
    #   '';
    # };

  };
}
