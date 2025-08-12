{ config, lib, pkgs, ... }:
let cfg = config.sys.timezone;
in {

  options = {
    sys.timezone.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic timezone detection based on geolocation.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable automatic timezone detection based on location
    services.automatic-timezoned.enable = true;
    
    # Set Vancouver as fallback timezone (lower priority so automatic-timezoned can override)
    time.timeZone = lib.mkDefault "America/Vancouver";
  };

}