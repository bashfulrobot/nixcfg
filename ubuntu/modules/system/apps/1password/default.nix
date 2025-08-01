{ config, pkgs, lib, ... }:
# 1Password system-level configuration for Ubuntu
# 
# This module configures 1Password at the system level with Ubuntu 24.04+ compatibility.
# Key features:
# - AppArmor profile to allow user namespace creation (required for Ubuntu 24.04+)
# - System-wide package installation
# - Browser integration files
# 
# Note: This module handles system-level concerns. User-level configuration
# should be done via the corresponding home-manager module.

let
  cfg = config.apps.onepassword;
in {
  options.apps.onepassword = {
    enable = lib.mkEnableOption "Enable 1Password system-level configuration with AppArmor profile for Ubuntu 24.04+ compatibility";
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

    # Note: polkit configuration not supported in system-manager
    # Manual polkit setup may be required for browser integration

    # Load AppArmor profile on system activation
    systemd.services."apparmor-1password" = {
      description = "Load 1Password AppArmor profile";
      wantedBy = [ "system-manager.target" ];
      after = [ "apparmor.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Use bash wrapper for better error handling
        ExecStart = pkgs.writeShellScript "load-1password-apparmor" ''
          set -euo pipefail
          if [[ ! -x "${pkgs.apparmor-utils}/bin/apparmor_parser" ]]; then
            echo "AppArmor utils not available, skipping profile load"
            exit 0
          fi
          if [[ ! -f "/etc/apparmor.d/1password" ]]; then
            echo "1Password AppArmor profile not found, skipping"
            exit 0
          fi
          echo "Loading 1Password AppArmor profile..."
          "${pkgs.apparmor-utils}/bin/apparmor_parser" -r /etc/apparmor.d/1password
        '';
        ExecReload = pkgs.writeShellScript "reload-1password-apparmor" ''
          set -euo pipefail
          if [[ -x "${pkgs.apparmor-utils}/bin/apparmor_parser" && -f "/etc/apparmor.d/1password" ]]; then
            "${pkgs.apparmor-utils}/bin/apparmor_parser" -r /etc/apparmor.d/1password
          fi
        '';
      };
      # Only run if AppArmor 4.0 is available (Ubuntu 24.04+)
      unitConfig.ConditionPathExists = "/etc/apparmor.d/abi/4.0";
    };
  };
}