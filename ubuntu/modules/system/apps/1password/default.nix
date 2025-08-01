{ config, pkgs, lib, ... }:

let
  cfg = config.apps.onepassword;
in {
  options.apps.onepassword = {
    enable = lib.mkEnableOption "Enable 1Password with browser integration";
    
    enableCLI = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install 1Password CLI system-wide";
    };
    
    enableBrowserIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable native messaging for browser integration";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-wide packages
    environment.systemPackages = with pkgs; [
      (lib.mkIf cfg.enableCLI _1password)
    ];

    # Polkit rules for 1Password browser integration
    environment.etc = lib.mkIf cfg.enableBrowserIntegration {
      "1password/custom_allowed_browsers".source = 
        "${pkgs._1password-gui}/share/1password/resources/custom_allowed_browsers";
    };

    # System-level polkit rules for 1Password authentication
    security.polkit.extraConfig = lib.mkIf cfg.enableBrowserIntegration ''
      polkit.addRule(function(action, subject) {
          if (action.id == "com.1password.1Password.unlock" &&
              subject.local == true &&
              subject.active == true &&
              subject.isInGroup("users")) {
              return polkit.Result.YES;
          }
      });
    '';
  };
}