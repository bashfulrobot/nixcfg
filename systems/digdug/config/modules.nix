{ config, pkgs, ... }: {

  users.default.enable = true;

  # Enable hyprland desktop
  desktops.hyprflake.enable = true;

  # Enable power management

  environment.systemPackages = with pkgs; [ mullvad ];

  services.mullvad-vpn.enable = false;

  apps.syncthing = {
    enable = true;
    host.digdug = true;
  };
}
