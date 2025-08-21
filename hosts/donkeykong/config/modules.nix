{ config, lib, pkgs, ... }:
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
    timezone.enable = true;
  };

  # Enable desktop environments
  desktops.gnome.enable = true;
  desktops.tiling.hyprland.enable = false;

  apps = {
    # claude-desktop.enable = true; # Temporarily disabled due to hash mismatch
  };

  # apps.syncthing = {
  #   enable = true;
  #   host.donkeykong = true;
  # };
}
