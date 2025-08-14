{ pkgs, config, lib, ... }:
let cfg = config.apps.gradia;
in {
  options = {
    apps.gradia.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Gradia screenshot application.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install Gradia via Flatpak
    services.flatpak.packages = [
      {
        appId = "be.alexandervanhee.gradia";
        origin = "flathub";
      }
    ];

    # Ensure flatpak is enabled
    sys.flatpaks.enable = true;
  };
}