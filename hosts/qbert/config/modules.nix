{ config, pkgs, ... }:
{

  users.default.enable = true;

  sys = {
    desktop-files = {
      enable = true;
      reboot-windows = true;

    };
    disable-stub-dns.enable = true;
    stylix-theme.wallpaperType = "personal";
    plymouth.backgroundType = "personal";
    timezone.enable = true;
  };

  # Enable gnome desktop
  desktops.gnome.enable = true;
  desktops.tiling = {
    hyprland.enable = false;
    niri.enable  = true;
  };

  apps = {
    claude-desktop.enable = true;
    syncthing = {
      enable = true;
      host.qbert = true;
    };
  };
}
