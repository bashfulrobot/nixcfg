{ config, pkgs, lib, ... }:

{
  # Git system-wide installation
  environment.systemPackages = with pkgs; [
    git
    git-crypt
  ];
}