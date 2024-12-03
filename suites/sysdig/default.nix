{ config, pkgs, lib, ... }:
let cfg = config.suites.sysdig;
in {

  options = {
    suites.sysdig.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable sysdig apps and tooling..";
    };
  };

  config = lib.mkIf cfg.enable {

    apps = {
      zoom-us.enable = true;
    };

    cli = {
      sysdig-cli-scanner.enable = true;
      instruqt.enable = true;
    };
  };
}
