{ config, pkgs, ... }:
{

  users.default.enable = true;

  sys = {
    desktop-files = {
      enable = true;
      reboot-windows = true;

    };
    disable-stub-dns.enable = true;
    stylix-theme.wallpaperType = "professional";
    plymouth.backgroundType = "professional";
  };

  # Enable gnome desktop
  desktops.gnome.enable = true;
  desktops.tiling.hyprland.enable = false;

  # apps.syncthing = {
  #   enable = true;
  #   host.donkeykong = true;
  # };
}
