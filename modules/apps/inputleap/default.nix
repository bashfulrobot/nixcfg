{ user-settings, pkgs, config, lib, ... }:
let cfg = config.apps.inputleap;
in {
  options = {
    apps.inputleap.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable InputLeap.";
    };
  };

  config = lib.mkIf cfg.enable {

    services.flatpak.packages = [
      "io.github.input_leap.input-leap" # Software KVM
    ];
  };
}
