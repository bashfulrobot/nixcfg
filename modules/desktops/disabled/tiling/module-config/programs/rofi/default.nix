{
  pkgs,
  lib,
  ...
}:
let
  terminal = "kitty";
in
{
  home-manager.sharedModules = [
    (_: {
      programs.rofi = let
        inherit (lib) getExe;
      in {
        enable = true;
        package = pkgs.rofi-wayland;
        terminal = "${getExe pkgs.${terminal}}";
        plugins = with pkgs; [
          rofi-emoji-wayland # https://github.com/Mange/rofi-emoji 🤯
          rofi-games # https://github.com/Rolv-Apneseth/rofi-games 🎮
        ];
      };
      xdg.configFile = {
        "rofi/config-music.rasi".source = ./config-music.rasi;
        "rofi/config-long.rasi".source = ./config-long.rasi;
        "rofi/config-wallpaper.rasi".source = ./config-wallpaper.rasi;
        "rofi/launchers" = {
          source = ./launchers;
          recursive = true;
        };
        "rofi/colors" = {
          source = ./colors;
          recursive = true;
        };
        "rofi/assets" = {
          source = ./assets;
          recursive = true;
        };
        "rofi/resolution" = {
          source = ./resolution;
          recursive = true;
        };
      };
    })
  ];
}
