{ user-settings, pkgs, config, lib, ... }:
let 
  cfg = config.apps.slack;
  
  # Toggle script for Wayland - uses keyboard shortcut to close window
  toggleSlackScript = pkgs.writeShellApplication {
    name = "toggle-slack";
    runtimeInputs = [ pkgs.wtype pkgs.procps ];
    text = ''
      # Check if Slack is running
      if pgrep -x "slack" > /dev/null; then
        # Slack is running - focus it first, then send Super+Q to close window (goes to tray)
        slack &
        sleep 0.3
        # Send Super+Q to close the window (will minimize to tray if configured)
        wtype -M logo -k q
      else
        # Slack is not running - launch it
        slack &
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

    # Install Slack and toggle script
    environment.systemPackages = with pkgs; [
      unstable.slack
      toggleSlackScript
    ];
  };
}