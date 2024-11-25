{ config, pkgs, ... }: {

  apps = { one-password.enable = true; };

  nixcfg = {
    nix-settings.enable = true;
    home-manager.enable = true;
  };
}
