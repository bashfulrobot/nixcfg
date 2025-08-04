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

{
  config = {
    # Note: 1Password packages now installed via home-manager for proper desktop integration
    # This module only handles system-level configuration (AppArmor, etc.)

    # Polkit rules for 1Password browser integration (always enabled)
    environment.etc = {
      # Custom allowed browsers file with zen browser support
      "1password/custom_allowed_browsers".text = ''
        firefox
        firefox-esr
        firefox-beta
        firefox-dev
        firefox-nightly
        google-chrome
        google-chrome-beta
        google-chrome-dev
        google-chrome-unstable
        chromium
        chromium-browser
        microsoft-edge
        microsoft-edge-beta
        microsoft-edge-dev
        brave
        brave-browser
        vivaldi
        opera
        zen
        zen-browser
      '';

      # AppArmor profile for 1Password to fix Ubuntu 24.04 user namespace restrictions
      "apparmor.d/1password-nix".text = ''
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
    systemd.services."apparmor-1password-nix" = {
      description = "Load 1Password AppArmor profile";
      wantedBy = [ "system-manager.target" ];
      after = [ "apparmor.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Use bash wrapper for better error handling
        ExecStart = pkgs.writeShellScript "load-1password-nix-apparmor" ''
          set -euo pipefail
          if [[ ! -x "${pkgs.apparmor-utils}/bin/apparmor_parser" ]]; then
            echo "AppArmor utils not available, skipping profile load"
            exit 0
          fi
          if [[ ! -f "/etc/apparmor.d/1password-nix" ]]; then
            echo "1Password AppArmor profile not found, skipping"
            exit 0
          fi
          echo "Loading 1Password AppArmor profile..."
          "${pkgs.apparmor-utils}/bin/apparmor_parser" -r /etc/apparmor.d/1password-nix
        '';
        ExecReload = pkgs.writeShellScript "reload-1password-nix-apparmor" ''
          set -euo pipefail
          if [[ -x "${pkgs.apparmor-utils}/bin/apparmor_parser" && -f "/etc/apparmor.d/1password-nix" ]]; then
            "${pkgs.apparmor-utils}/bin/apparmor_parser" -r /etc/apparmor.d/1password-nix
          fi
        '';
      };
      # Only run if AppArmor 4.0 is available (Ubuntu 24.04+)
      unitConfig.ConditionPathExists = "/etc/apparmor.d/abi/4.0";
    };
  };
}