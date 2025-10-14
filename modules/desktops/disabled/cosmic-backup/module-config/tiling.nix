{
  user-settings,
  config,
  lib,
  ...
}:

{
  # COSMIC Compositor and Tiling Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # Autotile configuration for COSMIC Comp
      "cosmic/com.system76.CosmicComp/v1/autotile" = {
        text = ''
          true
        '';
        force = true;
      };

      # Active hint configuration for COSMIC Comp
      "cosmic/com.system76.CosmicComp/v1/active_hint" = {
        text = ''
          true
        '';
        force = true;
      };

      # Autotile behavior configuration for COSMIC Comp
      "cosmic/com.system76.CosmicComp/v1/autotile_behavior" = {
        text = ''
          PerWorkspace
        '';
        force = true;
      };

      # Input touchpad configuration for COSMIC Comp
      "cosmic/com.system76.CosmicComp/v1/input_touchpad" = {
        text = ''
          (
              state: Enabled,
              acceleration: Some((
                  profile: Some(Adaptive),
                  speed: 0.0,
              )),
              click_method: Some(Clickfinger),
              disable_while_typing: Some(true),
              scroll_config: Some((
                  method: Some(TwoFinger),
                  natural_scroll: Some(false),
                  scroll_button: None,
                  scroll_factor: Some(6.062866266041593),
              )),
              tap_config: Some((
                  enabled: true,
                  button_map: Some(LeftRightMiddle),
                  drag: true,
                  drag_lock: false,
              )),
          )
        '';
        force = true;
      };

      # Input default configuration for COSMIC Comp
      "cosmic/com.system76.CosmicComp/v1/input_default" = {
        text = ''
          (
              libinput_config: (
                  click_method: None,
                  scroll_config: Some((
                      method: Some(TwoFinger),
                      natural_scroll: Some(false),
                      scroll_button: None,
                      scroll_factor: Some(1.0),
                  )),
                  tap_config: Some((
                      enabled: false,
                      button_map: None,
                      drag: false,
                      drag_lock: false,
                  )),
              ),
          )
        '';
        force = true;
      };

      # XWayland configuration for COSMIC Comp
      "cosmic/com.system76.CosmicComp/v1/xwayland_eavesdropping" = {
        text = ''
          (
              keyboard: r#None,
              pointer: false,
          )
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicComp/v1/descale_xwayland" = {
        text = ''
          r#false
        '';
        force = true;
      };
    };
  };
}