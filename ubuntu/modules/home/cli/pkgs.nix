{ config, pkgs, lib, ... }:
# General CLI packages for home-manager installation

{
  home.packages = with pkgs; [
    wcurl  # HTTP client with improved output
    # Note: atuin handled by programs.atuin.enable in fish.nix
  ];
}