# Base system-manager configuration for Ubuntu systems
# This module provides the required minimal configuration for system-manager
{ config, pkgs, lib, ... }:

{
  # Required system-manager configuration
  nixpkgs.hostPlatform = "x86_64-linux";
}