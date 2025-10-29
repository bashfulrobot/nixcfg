{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.desktops.tiling.hyprland;

  # Submap hint scripts using standard pattern
  submapScripts = with pkgs; [
    (writeShellScriptBin "submap-hints" (builtins.readFile ./scripts/submap-hints.sh))
  ];
in
{
  options = {
    desktops.tiling.submap-hints.enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable or false;
      description = "Enable submap hint system for Hyprland";
    };
  };

  config = lib.mkIf (cfg.enable or false && config.desktops.tiling.submap-hints.enable) {
    environment.systemPackages = with pkgs; [
      rofi  # Runtime dependency for submap hints
    ] ++ submapScripts;
  };
}