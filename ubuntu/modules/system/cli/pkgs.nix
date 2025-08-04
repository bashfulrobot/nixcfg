{ config, pkgs, lib, ... }:
# system-wide package installation

{
  config = {
    environment.systemPackages = with pkgs; [
      wcurl
      atuin
      systemd  # Provides systemd-tmpfiles needed by system-manager
    ];
  };
}