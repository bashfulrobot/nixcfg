{ user-settings, pkgs, config, lib, inputs, ... }:
let cfg = config.desktops.cosmic;
in {
  options = {
    desktops.cosmic.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable COSMIC Desktop Environment";
    };
  };

  config = lib.mkIf cfg.enable {

    # Enable stylix theming support
    sys.stylix-theme.enable = true;

    # Enable COSMIC Desktop Environment (NixOS 25.05+ native support)
    services = {
      desktopManager.cosmic.enable = true;
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.xwayland.enable = true;
    };

    # COSMIC configuration files
    home-manager.users."${user-settings.user.username}" = {
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