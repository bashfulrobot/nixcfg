{ config, pkgs, lib, ... }:

let
  cfg = config.apps.onepassword;
in {
  options.apps.onepassword = {
    enable = lib.mkEnableOption "Enable 1Password with desktop app, CLI and browser integration";
  };

  config = lib.mkIf cfg.enable {
    # System-wide packages (install everything)
    environment.systemPackages = with pkgs; [
      _1password-gui  # Desktop app
      _1password-cli  # CLI
    ];

    # Polkit rules for 1Password browser integration (always enabled)
    environment.etc = {
      "1password/custom_allowed_browsers".source =
        "${pkgs._1password-gui}/share/1password/resources/custom_allowed_browsers";
    };

    # System-level polkit rules for 1Password authentication (always enabled)
    security.polkit.extraConfig = ''
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