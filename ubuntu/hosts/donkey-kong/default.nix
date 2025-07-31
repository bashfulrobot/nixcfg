{ config, pkgs, user-settings, secrets, inputs, ... }:

{
  imports = [
    ./modules.nix
  ];

  # Basic home-manager configuration
  home = {
    username = user-settings.user.username;
    homeDirectory = user-settings.user.home;
    stateVersion = "25.05";
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Enable experimental nix features
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
    };
  };

  # Basic system packages that are useful on Ubuntu
  home.packages = with pkgs; [
    # System utilities
    htop
    tree
    wget
    curl
    unzip
    zip
    
    # Development tools
    git
    gh
    
    # Nix tools
    nix-tree
    nix-du
    comma
  ];

  # Enable XDG directories
  xdg.enable = true;
}