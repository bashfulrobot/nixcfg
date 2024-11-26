{ config, pkgs, ... }: {

  users.default.enable = true;

  

  # Enable gnome desktop
  desktops.gnome.enable = true;

  cli = { git.enable = true; };
}
