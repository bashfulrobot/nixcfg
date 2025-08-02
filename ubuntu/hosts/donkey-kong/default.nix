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

  # Note: Nix settings are managed via /etc/nix/nix.conf on Ubuntu
  # Use the ubuntu-update-nix-conf helper script to modify settings

  apps = {
    chromium.enable = true;
    onepassword.enable = true;
  };

  cli = {
    direnv = {
      enable = true;
      system = true;
    };
    fish = {
      enable = true; 
      system = true;
    };
    starship.enable = true;
  };

  sys = {
    fonts = {
      enable = true;
    };
    dconf = {
      enable = true;
    };
  };

}