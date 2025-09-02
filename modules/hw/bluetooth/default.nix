{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.hw.bluetooth;
in
{

  options = {
    hw.bluetooth.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable bluetooth hardware.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        Policy = {
          autoEnable = true;
        };
      };
    };

    services.blueman.enable = false;

    #environment.systemPackages = with pkgs; [
    #  blueman
    #];
  };
}
