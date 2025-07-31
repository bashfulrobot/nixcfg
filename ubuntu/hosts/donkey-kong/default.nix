{ config, pkgs, user-settings, secrets, inputs, ... }:

{
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

  # Enable theming modules
  sys = {
    stylix-theme = {
      enable = true;
    };
    gtk-theme = {
      enable = true;
    };
    fonts = {
      enable = true;
    };
    dconf = {
      enable = true;
    };
  };

  # Declarative Flatpak applications
  apps.flatpak = {
    enable = true;
    packages = [
      "flathub:app/com.todoist.Todoist//stable"
    ];
    
    # Keep packages up to date
    update = true;
    
    # Remove packages not managed by this config
    uninstallUnmanagedPackages = false; # Set to true for strict management
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