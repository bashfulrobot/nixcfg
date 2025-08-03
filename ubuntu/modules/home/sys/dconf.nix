{ config, pkgs, lib, ... }:
# GNOME dconf tools for settings management

{
    # Install dconf tools via home-manager
    home.packages = with pkgs; [
      dconf-editor
      dconf2nix
    ];
}