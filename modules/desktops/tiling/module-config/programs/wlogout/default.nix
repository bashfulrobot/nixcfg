{ config, lib, pkgs, ... }:

let
  buildTheme = pkgs.callPackage ../../../../../../lib/stylix-theme.nix { };
  style = buildTheme.build {
    inherit (config.lib.stylix) colors;
    file = builtins.readFile ./style.css;
    iconsPath = "${./icons}";
  };
in
{
  home-manager.sharedModules = [
    (_: {
      programs.wlogout = {
        enable = true;
        style = style;
        layout = [
          {
            label = "logout";
            action = "hyprctl dispatch exit 0";
            text = "Logout";
            keybind = "e";
          }
          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
          }
          {
            label = "suspend";
            action = "systemctl suspend";
            text = "Suspend";
            keybind = "u";
          }
          {
            label = "reboot";
            action = "systemctl reboot";
            text = "Reboot";
            keybind = "r";
          }
        ];
      };
    })
  ];
}
