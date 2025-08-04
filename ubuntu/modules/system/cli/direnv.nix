{ config, pkgs, lib, ... }:
# Direnv system-wide package installation

{
  config = {
    environment.systemPackages = with pkgs; [
      direnv
    ];
  };
}