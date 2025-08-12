{ config, lib, ... }:
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
    # Enable automatic timezone detection service
    services.automatic-timezoned.enable = true;
    
    # Set default timezone with lower priority to allow automatic-timezoned to override
    time.timeZone = lib.mkDefault "America/Vancouver";
  };

}