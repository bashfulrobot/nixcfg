{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./config/autoimport.nix
    ../../modules/autoimport.nix
  ];

  nixcfg = {
    nix-settings.enable = true;
    home-manager.enable = true;
  };
  
}
