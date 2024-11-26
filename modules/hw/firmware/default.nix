{ pkgs, config, lib, ... }:
let cfg = config.hw.firmware;
in {

  options = {
    hw.firmware.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable firmware updates.";
    };
  };

  config = lib.mkIf cfg.enable {

    hardware.enableRedistributableFirmware = true; # For some unfree drivers
    # systemd.services.systemd-udev-settle.enable = false;
    services.fwupd.enable = true;
    # services.fstrim.enable = true;

    environment.systemPackages = with pkgs;
      [

      ];
  };
}
# sudo alsactl store - fixes  error: failed to import hw:0 use case configuration -2
