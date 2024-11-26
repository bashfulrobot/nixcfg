{ config, pkgs, ... }: {

  nixcfg = {
    nix-settings.enable = true;
    home-manager.enable = true;
  };

  # Enable gnome desktop
  desktops.gnome.enable = true;

  apps = { one-password.enable = true; };

  cli = { git.enable = true; };
}
