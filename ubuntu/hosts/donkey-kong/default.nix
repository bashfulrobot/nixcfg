{ config, pkgs, user-settings, secrets, inputs, ... }:
# Donkey-Kong workstation configuration
# Ubuntu configuration using auto-import architecture
# All modules are automatically enabled - no manual configuration needed

{
  # Basic home-manager configuration
  home = {
    username = user-settings.user.username;
    homeDirectory = user-settings.user.home;
    stateVersion = "25.05";
  };

  # XDG settings
  xdg.enable = true;

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Note: Nix settings are managed via /etc/nix/nix.conf on Ubuntu
  # Use the ubuntu-update-nix-conf helper script to modify settings

}