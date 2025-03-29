{ pkgs, lib, ... }:
{

  imports = [
    ./homebrew.nix
    ./osx.nix
    ./nixpkgs.nix
    ./user.nix
    ./hm.nix
    ./modules.nix
  ];

  networking.hostName = "dustinkrysak"; # Define your hostname.

  programs.fish.enable = true;
  # bash is enabled by default

  # Determinate uses its own daemon to manage the Nix installation that conflicts with nix-darwin’s native Nix management.

  nix.enable = false;

  system.stateVersion = 5;
}
