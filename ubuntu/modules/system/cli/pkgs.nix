{ config, pkgs, lib, ... }:
# system-wide package installation

{
  config = {
    environment.systemPackages = with pkgs; [
      wcurl
      atuin
      # systemd already provided by Ubuntu system, don't install via Nix
    ];
  };
}