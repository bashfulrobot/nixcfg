{ config, pkgs, lib, ... }:
# Direnv system-wide package installation

{
  environment.systemPackages = with pkgs; [
    direnv
  ];
}