{
  config,
  lib,
  pkgs,
  ...
}:
{

  users.default.enable = true;

  sys = {
    desktop-files = {
      enable = true;
      reboot-windows = false;

    };
    disable-stub-dns.enable = true;
    power.clamshell = true;
    stylix-theme.wallpaperType = "professional";
    plymouth.backgroundType = "professional";
    timezone.enable = true;
  };

  # Enable desktop environments
  desktops = {
    cosmic.enable = true;
    # gnome.enable = false;
  # tiling.hyprland.enable = false;
  };

  apps = {

  };

  # apps.syncthing = {
  #   enable = true;
  #   host.donkeykong = true;
  # };
}
