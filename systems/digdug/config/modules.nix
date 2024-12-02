{ config, pkgs, ... }: {

  users.default.enable = true;

  # Enable gnome desktop
  desktops.gnome.enable = true;

  environment.systemPackages = with pkgs; [ mullvad ];

  services.mullvad-vpn.enable = true;
}
