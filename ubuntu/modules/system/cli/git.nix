{ config, pkgs, lib, ... }:

{
  config = {
    # Git system-wide installation
    environment.systemPackages = with pkgs; [
      git
      git-crypt
    ];
  };
}