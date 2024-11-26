{ config, pkgs, ... }: {

  users.default.enable = true;

  

  # Enable gnome desktop
  desktops.gnome.enable = true;

  apps = { one-password.enable = true; };

  cli = { git.enable = true; };
}
