{ config, pkgs, lib, ... }:
# system-wide package installation

{
  environment.systemPackages = with pkgs; [
    wcurl
  ];
}