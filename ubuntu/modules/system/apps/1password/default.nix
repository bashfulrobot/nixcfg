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

      # AppArmor profile for 1Password to fix Ubuntu 24.04 user namespace restrictions
      "apparmor.d/1password".text = ''
        # This profile allows 1Password to create user namespaces for sandboxing
        # Fixes Ubuntu 24.04+ restriction: kernel.apparmor_restrict_unprivileged_userns=1

        abi <abi/4.0>,
        include <tunables/global>

        profile 1password ${pkgs._1password-gui}/share/1password/1password flags=(unconfined) {
            userns,

            # Site-specific additions and overrides
            include if exists <local/1password>
        }
      '';
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

    # Load AppArmor profile on system activation
    systemd.services."apparmor-1password" = {
      description = "Load 1Password AppArmor profile";
      wantedBy = [ "multi-user.target" ];
      after = [ "apparmor.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.apparmor-utils}/bin/apparmor_parser -r /etc/apparmor.d/1password";
        ExecReload = "${pkgs.apparmor-utils}/bin/apparmor_parser -r /etc/apparmor.d/1password";
      };
      # Only run if AppArmor 4.0 is available (Ubuntu 24.04+)
      unitConfig.ConditionPathExists = "/etc/apparmor.d/abi/4.0";
    };
  };
}