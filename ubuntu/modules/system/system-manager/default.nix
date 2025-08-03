{ config, lib, pkgs, user-settings, ... }:
# Base system-manager configuration
#
# This module provides the fundamental system-manager configuration required
# for all Ubuntu systems. It sets the host platform and provides access to
# user settings for other modules.

{
  # Required system-manager configuration
  nixpkgs.hostPlatform = "x86_64-linux";
  
  # Allow unfree packages in system-manager
  nixpkgs.config.allowUnfree = true;
  
  # Make user-settings available to all system modules via extraSpecialArgs
  # This allows modules to access user configuration like username, paths, etc.
  
  # Basic system configuration can go here if needed
  # For now, this serves as the base configuration entry point
}