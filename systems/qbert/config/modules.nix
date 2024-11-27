{ config, pkgs, ... }: {

  users.default.enable = true;

  apps.desktopFile = {
    enable = true;
    reboot-windows = true;
  };

  # Enable gnome desktop
  desktops.gnome.enable = true;

  cli = { git.enable = true; };
}
