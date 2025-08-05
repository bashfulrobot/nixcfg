{
  config,
  pkgs,
  lib,
  ...
}:
# General CLI packages for home-manager installation

{
  home.packages = with pkgs; [
    # Note: atuin handled by programs.atuin.enable in fish.nix
  ];
}
