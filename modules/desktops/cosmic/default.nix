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

    # Enable GCR SSH agent for SSH key management (COSMIC doesn't start SSH agent automatically)
    # TODO: Replace with services.gnome.gcr-ssh-agent.enable = true when upgrading to unstable
    # Manual implementation of gcr-ssh-agent service (will be available in nixos-unstable)
    systemd.user.sockets.gcr-ssh-agent = {
      description = "GCR SSH Agent socket";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = "%t/gcr/ssh";
        FileDescriptorName = "ssh";
        SocketMode = "0600";
        DirectoryMode = "0700";
      };
    };

    systemd.user.services.gcr-ssh-agent = {
      description = "GCR SSH Agent";
      requires = [ "gcr-ssh-agent.socket" ];
      after = [ "gcr-ssh-agent.socket" ];
      # Prevent GCR from autostarting ssh-agent
      environment.GSK_SSH_AUTH_SOCK = "";
      serviceConfig = {
        ExecStart = "${pkgs.gcr_4}/libexec/gcr4-ssh-askpass --socket";
        StandardInput = "socket";
        StandardOutput = "null";
      };
    };

    # Enable COSMIC Desktop Environment (NixOS 25.05+ native support)
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.xwayland.enable = true;
    };

    # COSMIC configuration files
    home-manager.users."${user-settings.user.username}" = {
      # SSH agent environment variables (GCR SSH agent socket)
      home.sessionVariables = {
        SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
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
