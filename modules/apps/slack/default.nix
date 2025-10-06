{ user-settings, pkgs, config, lib, ... }:
let 
  cfg = config.apps.slack;

in {

  options = {
    apps.slack = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Slack.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # Install Slack
    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      unstable.slack
      # keep-sorted end
    ];
  };
}