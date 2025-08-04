{ config, lib, pkgs, ... }:
# Base system-manager configuration
#
# This module provides the fundamental system-manager configuration required
# for all Ubuntu systems. It sets the host platform and provides access to
# user settings for other modules.

{
  config = {
    # Required system-manager configuration
    nixpkgs.hostPlatform = "x86_64-linux";
    
    # Allow unfree packages in system-manager
    nixpkgs.config.allowUnfree = true;
    
    # Note: PATH configuration handled automatically by system-manager
  };
}