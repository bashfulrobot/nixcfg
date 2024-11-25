{ config, lib, ... }: {
  nixcfg = {
    nix-settings.enable = true;
    home-manager.enable = true;
  };
}
