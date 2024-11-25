{ config, pkgs, ... }: {
  nixcfg = {
    nix-settings.enable = true;
    home-manager.enable = true;
  };
}
