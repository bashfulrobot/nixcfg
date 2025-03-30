{ pkgs, lib, ... }:
{

  imports = [
    ./homebrew.nix
    ./osx.nix
    ./nixpkgs.nix
    ./user.nix
    ./hm.nix
    ./modules.nix
    ./nix-settings.nix
  ];

  networking = {
    hostName = "dustinkrysak"; # Define your hostname.
    # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-networking.computerName
    computerName = "dustinkrysak";
    # Enable WOL
    wakeOnLan.enable = true;
  };

  programs.fish.enable = true;
  # bash is enabled by default

}
