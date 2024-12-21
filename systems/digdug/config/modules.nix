{ config, pkgs, ... }: {

  users.default.enable = true;

  # Enable gnome desktop
  desktops.gnome.enable = true;

  # Enable power management

  environment.systemPackages = with pkgs; [ mullvad ];

  services.mullvad-vpn.enable = true;

  apps.syncthing = {
    enable = true;
    host.digdug = true;
  };
}
