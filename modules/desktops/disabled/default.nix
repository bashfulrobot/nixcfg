{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.desktops.niri;
in
{
  options = {
    desktops.niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri Desktop.";
    };
  };

  config = lib.mkIf cfg.enable {
    imports = [
      ./module-config/nixpkgs.nix
      ./module-config/niri-settings.nix
      ./module-config/ironbar-settings.nix
      ./module-config/eww-settings.nix
      ./module-config/onagre-settings.nix
    ];

    programs = {
      niri = {
        enable = true;
        package = pkgs.unstable.niri;
      };
      dconf.enable = true;
      xwayland.enable = true;
    };

    security.polkit.enable = true;

    # XDG portal for screenshot support and other desktop integration
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # home-manager.users."${user-settings.user.username}" = {

    # };
  };
}
