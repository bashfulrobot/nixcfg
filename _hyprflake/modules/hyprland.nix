{ config, lib, pkgs, ... }:

{
  # Placeholder for Hyprland system-level configuration
  # Will be populated when porting from main nixcfg

  imports = [ ];

  # Enable Hyprland as window manager
  programs.hyprland.enable = lib.mkDefault true;
}