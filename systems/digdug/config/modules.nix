{ config, lib, ... }: {

  config.nixcfg = {
    nix-settings.enable = true;
    home-manager.enable = true;
  };
}
