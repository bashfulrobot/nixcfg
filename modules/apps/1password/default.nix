{ user-settings, config, lib, secrets, pkgs, inputs, ... }:

let
  cfg = config.apps.one-password;
  onePassPath = "~/.1password/agent.sock";

  # Beta version override - set to false for stable version
  useBeta = true;

  # Create beta package overlay
  _1password-gui-beta = pkgs._1password-gui.overrideAttrs (oldAttrs: rec {
    version = "8.11.6-25.BETA";
    src =
      if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
        pkgs.fetchurl {
          url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz";
          hash = "sha256-gOq2Yl4HmwrmV41iwPQ1jFEHUv6TydTBHLGecgiiRxE=";
        }
      else
        pkgs.fetchurl {
          url = "https://downloads.1password.com/linux/tar/beta/aarch64/1password-${version}.arm64.tar.gz";
          hash = "sha256-fRgTfZjQRrPbYUKIub+y9iYSBvsElN90ag0maPKTM2g=";
        };
  });

  # Choose package based on beta flag
  selectedGuiPackage = if useBeta then _1password-gui-beta else pkgs.unstable._1password-gui;

in {

  options = {
    apps.one-password.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable one-password.";
    };
  };

  config = lib.mkIf cfg.enable {

    # The 1Password app can unlock your browser extension using a special native messaging process. This streamlines your 1Password experience: Once you unlock 1Password from your tray icon, your browser extensions will be unlocked as well.
    environment.etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          chromium
          zen
          zen-bin
        '';
        mode = "0755";
      };
    };

    # Enable the 1Passsword GUI with myself as an authorized user for polkit
    programs = {
      _1password = {
        enable = true;
        package = pkgs.unstable._1password-cli;
      };
      _1password-gui = {
        enable = true;
        package = selectedGuiPackage;
        # polkitPolicyOwners = [ "${user-settings.user.username}" ];
        polkitPolicyOwners = [ "dustin" ];
        # polkitPolicyOwners = config.users.groups.wheel.members;
      };

    };

    # used in Gnome and Hyprland
    home-manager.users."${user-settings.user.username}" = {
      home.file."1password.desktop" = {
        source = ./1password.desktop;
        target = ".config/autostart/1password.desktop";
      };

      # SSH configuration to use 1Password SSH agent
      # TODO: TEST this
      # programs.ssh = {
      #   enable = true;
      #   extraConfig = ''
      #     Host *
      #         IdentityAgent ~/.1password/agent.sock
      #   '';
      # };

    };
  };
}
