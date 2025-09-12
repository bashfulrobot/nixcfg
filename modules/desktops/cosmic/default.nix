{
  user-settings,
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.desktops.cosmic;

  # Import our custom COSMIC build module
  cosmicBuild = import ./build {
    inherit pkgs lib;
    fetchFromGitHub = pkgs.fetchFromGitHub;
  };
in
{
  options = {
    desktops.cosmic.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable COSMIC Desktop Environment";
    };
  };

  config = lib.mkIf cfg.enable {

    # Enable dev.cachix for personal cache functionality
    dev.cachix.enable = true;

    # COSMIC binary cache for faster package downloads
    nix.settings = {
      substituters = cosmicBuild.binaryCache.substituters ++ [ "https://bashfulrobot.cachix.org" ];
      trusted-public-keys = cosmicBuild.binaryCache.trusted-public-keys ++ [ "bashfulrobot.cachix.org-1:dV0OEgd/ccYivTMyL8nsIE4nmlSZs+X30bTrvgPL7rg=" ];
    };

    # System packages
    environment.systemPackages = with pkgs; [
      inotify-tools # used to observe file changes when learning where settings are stored.
      gnome-keyring
      libsecret
      gcr_4 # GCR 4.x for modern keyring password prompts
      seahorse # GUI keyring manager
    ];

    # Enhance XDG data discovery for better MIME/application integration
    # Based on GNOME's approach but adapted for COSMIC's minimal philosophy
    # This helps resolve issues with default application selection (e.g., Zoom SSO browser choice)
    # by ensuring applications can properly discover MIME associations and desktop files
    environment.sessionVariables = {
      # Help applications find MIME associations and desktop files
      XDG_DATA_DIRS = [ "$XDG_DATA_DIRS" "/run/current-system/sw/share" ];
      # Ensure proper COSMIC desktop identification
      XDG_CURRENT_DESKTOP = "COSMIC";
      XDG_SESSION_DESKTOP = "cosmic";
    };

    # Enable stylix theming support
    sys.stylix-theme.enable = true;

    # Enable COSMIC Desktop Environment (NixOS 25.05+ native support)
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.xwayland.enable = true;
    };

    # Exclude specific COSMIC packages if needed
    environment.cosmic.excludePackages = with pkgs; [
      # cosmic-edit
      # cosmic-player
    ];

    # Apply our custom COSMIC overlay with pinned package versions (nightly builds available for fixes I need. TODO: Will remove once the beta releases are out)
    nixpkgs.overlays = [ cosmicBuild.cosmicOverlay ];

    # Configure xdg-desktop-portal for proper URL handling
    # COSMIC portal doesn't support AppChooser interface, so use GTK backend
    # Note: xdg.portal.enable and extraPortals are already configured by the COSMIC service
    xdg.portal.config.cosmic = {
      default = [ "cosmic" "gtk" ];
      "org.freedesktop.impl.portal.AppChooser" = [ "gtk" ];
    };

    # Setup user profile picture in AccountsService
    system.activationScripts.setupFaceFile.text = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      cp ${./.face} /var/lib/AccountsService/icons/${user-settings.user.username}
      echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${user-settings.user.username}\n" > /var/lib/AccountsService/users/${user-settings.user.username}

      chown root:root /var/lib/AccountsService/users/${user-settings.user.username}
      chmod 0600 /var/lib/AccountsService/users/${user-settings.user.username}

      chown root:root /var/lib/AccountsService/icons/${user-settings.user.username}
      chmod 0444 /var/lib/AccountsService/icons/${user-settings.user.username}
    '';

    # COSMIC configuration files
    home-manager.users."${user-settings.user.username}" = {
      # Create feature flag for COSMIC
      home.file.".config/nix-flags/cosmic-enabled".text = "";

      # SSH environment - use GNOME Keyring SSH socket
      home.sessionVariables = {
        SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
        # Ensure browsers can find desktop portal for URL handling
        XDG_CURRENT_DESKTOP = "COSMIC";
        # Ensure proper desktop integration for applications
        XDG_SESSION_DESKTOP = "cosmic";
        # Help applications find the correct desktop portals
        XDG_SESSION_TYPE = "wayland";
      };

      xdg.configFile = {
        # Autotile configuration for COSMIC Comp
        "cosmic/com.system76.CosmicComp/v1/autotile".text = ''
          true
        '';

        # Active hint configuration for COSMIC Comp
        "cosmic/com.system76.CosmicComp/v1/active_hint".text = ''
          true
        '';

        # Autotile behavior configuration for COSMIC Comp
        "cosmic/com.system76.CosmicComp/v1/autotile_behavior".text = ''
          PerWorkspace
        '';

        # Input touchpad configuration for COSMIC Comp
        "cosmic/com.system76.CosmicComp/v1/input_touchpad".text = ''
          (
              state: Enabled,
              click_method: Some(Clickfinger),
              scroll_config: Some((
                  method: Some(TwoFinger),
                  natural_scroll: None,
                  scroll_button: None,
                  scroll_factor: None,
              )),
              tap_config: Some((
                  enabled: true,
                  button_map: Some(LeftRightMiddle),
                  drag: true,
                  drag_lock: false,
              )),
          )
        '';
      };
    };

  };
}
