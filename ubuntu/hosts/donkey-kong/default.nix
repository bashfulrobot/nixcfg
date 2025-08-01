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
    };
  };

  apps = {
    chromium.enable = true;
    onepassword.enable = true;
  };

  cli = {
    direnv.enable = true;
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