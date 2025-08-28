{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.desktops.tiling.niri;

in
{
  options = {
    desktops.tiling.niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri tiling Wayland compositor";
    };
  };

  imports = [
    ./module-config
  ];

  config = lib.mkIf cfg.enable {
    # NixOS Configuration

    nix.settings = {
      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
    };

    home-manager.users."${user-settings.user.username}" = {
      # Home Manager Configuration

    };
  };
}
