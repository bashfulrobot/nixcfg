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
      confluence.enable = true;
      gcal-sysdig.enable = true;
      gmail-sysdig.enable = true;
      intercom.enable = true;
      jira.enable = true;
      sfdc.enable = true;
      # TODO: Enable Gainsight
      };

    cli = {
      sysdig-cli-scanner.enable = true;
      instruqt.enable = true;
    };

    environment.systemPackages = with pkgs; [ rocketchat-desktop ];

  };
}
