# System-manager implementation for direnv
{ config, pkgs, lib, ... }:

let
  cfg = config.programs.direnv;
in {
  # Only apply when in system-manager context
  config = lib.mkIf (cfg.enable && (config ? environment)) {
    # System-level packages for direnv support
    environment.systemPackages = with pkgs; [ 
      envsubst  # Required for envsubst functionality
      direnv    # Make direnv available system-wide
    ];
  };
}