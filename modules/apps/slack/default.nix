{ user-settings, pkgs, config, lib, ... }:
let 
  cfg = config.apps.slack;
  
  # Toggle script for Wayland - uses dex to launch and proper key combination to close
  toggleSlackScript = pkgs.writeShellApplication {
    name = "toggle-slack";
    runtimeInputs = [ pkgs.wtype pkgs.procps pkgs.dex ];
    text = ''
      # Check if Slack is running
      if pgrep -x "slack" > /dev/null; then
        # Slack is running - send Super+Q to close window (will minimize to tray if configured)
        wtype -M logo q -m logo
      else
        # Slack is not running - launch it using desktop file for proper behavior
        dex /run/current-system/sw/share/applications/slack.desktop
      fi
    '';
  };

in {

  options = {
    apps.slack = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Slack with toggle functionality.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # Install Slack, wtype for Wayland input, dex for desktop file launching, and toggle script
    environment.systemPackages = with pkgs; [
      unstable.slack
      wtype
      dex
      toggleSlackScript
    ];
  };
}