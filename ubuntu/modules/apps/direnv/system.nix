# System-manager implementation for direnv
{ config, pkgs, lib, ... }:

let
  cfg = config.cli.direnv;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      direnv
    ];

    # Optionally configure any system-wide direnv settings here
  };
}