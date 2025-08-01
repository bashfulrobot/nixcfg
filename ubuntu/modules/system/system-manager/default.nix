{ config, lib, pkgs, user-settings, ... }:
# Base system-manager configuration
#
# This module provides the fundamental system-manager configuration required
# for all Ubuntu systems. It sets the host platform and provides access to
# user settings for other modules.

{
  # Required system-manager configuration
  nixpkgs.hostPlatform = "x86_64-linux";
  
  # Make user-settings available to all system modules via extraSpecialArgs
  # This allows modules to access user configuration like username, paths, etc.
  
  # System-wide nix configuration for sandbox compatibility
  nix.settings = {
    sandbox = "relaxed";
    extra-sandbox-paths = [
      "/usr/bin/env"
    ];
  };
}