{
  user-settings,
  config,
  lib,
  ...
}:

{
  # COSMIC Core Desktop Configuration
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

      # COSMIC Panel spacing configurations
      "cosmic/com.system76.CosmicPanel.Panel/v1/spacing" = {
        text = ''
          4
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/spacing" = {
        text = ''
          4
        '';
        force = true;
      };

      # Time applet configuration - enable 24-hour military time
      "cosmic/com.system76.CosmicAppletTime/v1/military_time" = {
        text = ''
          true
        '';
        force = true;
      };

      # COSMIC Files configurations
      "cosmic/com.system76.CosmicFiles/v1/tab" = {
        text = ''
          (
              folders_first: true,
              icon_sizes: (
                  list: 100,
                  grid: 100,
              ),
              show_hidden: false,
              single_click: false,
              view: List,
          )
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicFiles/v1/show_details" = {
        text = ''
          false
        '';
        force = true;
      };

      # COSMIC Panel autohide configuration
      "cosmic/com.system76.CosmicPanel.Panel/v1/autohide" = {
        text = ''
          Some((
              wait_time: 1000,
              transition_time: 200,
              handle_size: 4,
          ))
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/exclusive_zone" = {
        text = ''
          false
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/opacity" = {
        text = ''
          1.0
        '';
        force = true;
      };

      # COSMIC Panel layout and spacing
      "cosmic/com.system76.CosmicPanel.Panel/v1/margin" = {
        text = ''
          4
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/padding" = {
        text = ''
          0
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/autohover_delay_ms" = {
        text = ''
          Some(500)
        '';
        force = true;
      };

      # COSMIC Toolkit window controls - minimal interface
      "cosmic/com.system76.CosmicTk/v1/show_maximize" = {
        text = ''
          false
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicTk/v1/show_minimize" = {
        text = ''
          false
        '';
        force = true;
      };

      # COSMIC Panel border radius
      "cosmic/com.system76.CosmicPanel.Panel/v1/border_radius" = {
        text = ''
          8
        '';
        force = true;
      };

      # COSMIC Panel entries configuration
      "cosmic/com.system76.CosmicPanel/v1/entries" = {
        text = ''
          [
              "Panel",
          ]
        '';
        force = true;
      };

      # COSMIC Theme Mode Configuration
      "cosmic/com.system76.CosmicTheme.Mode/v1/auto_switch" = {
        text = ''
          false
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicTheme.Mode/v1/is_dark" = {
        text = ''
          true
        '';
        force = true;
      };
    };
  };
}