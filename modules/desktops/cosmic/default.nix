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

    # System packages
    environment.systemPackages = with pkgs; [
      inotify-tools # used to observe file changes when learning where settings are stored.
      gnome-keyring
      libsecret
      gcr_4 # GCR 4.x for modern keyring password prompts
      seahorse # GUI keyring manager
    ];

    # Enable stylix theming support
    sys.stylix-theme.enable = true;

    # Enable SSH agent with GCR askpass for keyring integration
    # TODO: Replace with services.gnome.gcr-ssh-agent.enable = true when upgrading to unstable
    programs.ssh.startAgent = true;

    # Enable COSMIC Desktop Environment (NixOS 25.05+ native support)
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.xwayland.enable = true;
    };

    # COSMIC configuration files
    home-manager.users."${user-settings.user.username}" = {
      # SSH askpass environment variable (use GCR for keyring integration)
      home.sessionVariables = {
        SSH_ASKPASS = "${pkgs.gcr_4}/libexec/gcr4-ssh-askpass";
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
