{ config, pkgs, lib, ... }:

let
  cfg = config.apps.chromium;
in {
  options.apps.chromium = {
    enable = lib.mkEnableOption "Enable Chromium system-level configuration";
  };

  config = lib.mkIf cfg.enable {
    # AppArmor profile for Chromium to fix Ubuntu 24.04 user namespace restrictions
    environment.etc."apparmor.d/chromium".text = ''
      # This profile allows Chromium to create user namespaces for sandboxing
      # Fixes Ubuntu 24.04+ restriction: kernel.apparmor_restrict_unprivileged_userns=1

      abi <abi/4.0>,
      include <tunables/global>

      profile chromium ${pkgs.chromium}/bin/chromium flags=(unconfined) {
          userns,

          # Site-specific additions and overrides
          include if exists <local/chromium>
      }
    '';

    # Load AppArmor profile on system activation
    systemd.services."apparmor-chromium" = {
      description = "Load Chromium AppArmor profile";
      wantedBy = [ "multi-user.target" ];
      after = [ "apparmor.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.apparmor-utils}/bin/apparmor_parser -r /etc/apparmor.d/chromium";
        ExecReload = "${pkgs.apparmor-utils}/bin/apparmor_parser -r /etc/apparmor.d/chromium";
      };
      # Only run if AppArmor 4.0 is available (Ubuntu 24.04+)
      unitConfig.ConditionPathExists = "/etc/apparmor.d/abi/4.0";
    };
  };
}