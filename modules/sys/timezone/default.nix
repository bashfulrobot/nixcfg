{ config, lib, pkgs, ... }:
let cfg = config.sys.timezone;
in {

  options = {
    sys.timezone.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable timezone configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Set Chicago timezone
    time.timeZone = "America/Chicago";
  };

}