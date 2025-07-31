{ user-settings, pkgs, config, lib, ... }:
let cfg = config.apps.distrobox;
in {
  options = {
    apps.distrobox.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Distrobox with Podman.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    environment.systemPackages = [ pkgs.distrobox ];
  };
}