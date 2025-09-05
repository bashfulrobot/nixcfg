{ user-settings, pkgs, config, lib, ... }:
let 
  cfg = config.apps.slack;
  
  # Toggle script for Wayland - simpler approach using process management
  toggleSlackScript = pkgs.writeShellApplication {
    name = "toggle-slack";
    text = ''
      # Check if Slack is running
      if pgrep -x "slack" > /dev/null; then
        # Slack is running - terminate it (will minimize to tray due to "close to tray" setting)
        pkill -TERM slack
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