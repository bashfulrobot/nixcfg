{ config, pkgs, lib, ... }:
# Chromium system-level configuration for Ubuntu
#
# This module provides system-level Chromium configuration for Ubuntu 24.04+.
# Key features:
# - AppArmor profile enabling user namespace creation for proper sandboxing
# - Fixes Ubuntu 24.04+ restriction: kernel.apparmor_restrict_unprivileged_userns=1
# 
# The AppArmor profile allows Chromium to create user namespaces which are
# essential for the browser's security sandboxing but restricted by default
# in Ubuntu 24.04+.
#
# Note: This module only handles system-level AppArmor configuration.
# User-level Chromium configuration (extensions, settings, etc.) should be
# done via the corresponding home-manager module.

let
  cfg = config.apps.chromium;
in {
  options.apps.chromium = {
    enable = lib.mkEnableOption "Enable Chromium system-level configuration with AppArmor profile for Ubuntu 24.04+ user namespace support";
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
      wantedBy = [ "system-manager.target" ];
      after = [ "apparmor.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Use bash wrapper for better error handling
        ExecStart = pkgs.writeShellScript "load-chromium-apparmor" ''
          set -euo pipefail
          if [[ ! -x "${pkgs.apparmor-utils}/bin/apparmor_parser" ]]; then
            echo "AppArmor utils not available, skipping profile load"
            exit 0
          fi
          if [[ ! -f "/etc/apparmor.d/chromium" ]]; then
            echo "Chromium AppArmor profile not found, skipping"
            exit 0
          fi
          echo "Loading Chromium AppArmor profile..."
          "${pkgs.apparmor-utils}/bin/apparmor_parser" -r /etc/apparmor.d/chromium
        '';
        ExecReload = pkgs.writeShellScript "reload-chromium-apparmor" ''
          set -euo pipefail
          if [[ -x "${pkgs.apparmor-utils}/bin/apparmor_parser" && -f "/etc/apparmor.d/chromium" ]]; then
            "${pkgs.apparmor-utils}/bin/apparmor_parser" -r /etc/apparmor.d/chromium
          fi
        '';
      };
      # Only run if AppArmor 4.0 is available (Ubuntu 24.04+)
      unitConfig.ConditionPathExists = "/etc/apparmor.d/abi/4.0";
    };
  };
}