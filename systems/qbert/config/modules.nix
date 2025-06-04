{ config, pkgs, ... }:
{

  users.default.enable = true;

  sys = {
    desktop-files = {
      enable = true;
      reboot-windows = true;

    };
    disable-stub-dns.enable = true;
  };

  # Enable gnome desktop
  desktops.gnome.enable = true;

  apps.syncthing = {
    enable = true;
    host.qbert = true;
  };
}
