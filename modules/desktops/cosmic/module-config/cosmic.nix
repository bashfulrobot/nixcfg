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

      # Input default configuration for COSMIC Comp
      "cosmic/com.system76.CosmicComp/v1/input_default".text = ''
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

      # XWayland configuration for COSMIC Comp
      "cosmic/com.system76.CosmicComp/v1/xwayland_eavesdropping".text = ''
        (
            keyboard: r#None,
            pointer: false,
        )
      '';

      "cosmic/com.system76.CosmicComp/v1/descale_xwayland".text = ''
        r#false
      '';

      # COSMIC Panel spacing configurations
      "cosmic/com.system76.CosmicPanel.Panel/v1/spacing".text = ''
        4
      '';

      "cosmic/com.system76.CosmicPanel.Dock/v1/spacing".text = ''
        4
      '';

      # Time applet configuration - enable 24-hour military time
      "cosmic/com.system76.CosmicAppletTime/v1/military_time".text = ''
        true
      '';

      # COSMIC Files configurations
      "cosmic/com.system76.CosmicFiles/v1/tab".text = ''
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

      "cosmic/com.system76.CosmicFiles/v1/show_details".text = ''
        false
      '';

      # COSMIC Panel autohide configuration
      "cosmic/com.system76.CosmicPanel.Panel/v1/autohide".text = ''
        Some((
            wait_time: 1000,
            transition_time: 200,
            handle_size: 4,
        ))
      '';

      "cosmic/com.system76.CosmicPanel.Panel/v1/exclusive_zone".text = ''
        false
      '';

      "cosmic/com.system76.CosmicPanel.Panel/v1/opacity".text = ''
        1.0
      '';

      # COSMIC Panel layout and spacing
      "cosmic/com.system76.CosmicPanel.Panel/v1/margin".text = ''
        4
      '';

      "cosmic/com.system76.CosmicPanel.Panel/v1/padding".text = ''
        0
      '';

      "cosmic/com.system76.CosmicPanel.Panel/v1/autohover_delay_ms".text = ''
        Some(500)
      '';

      # COSMIC Toolkit window controls - minimal interface
      "cosmic/com.system76.CosmicTk/v1/show_maximize".text = ''
        false
      '';

      "cosmic/com.system76.CosmicTk/v1/show_minimize".text = ''
        false
      '';

      # COSMIC Panel border radius
      "cosmic/com.system76.CosmicPanel.Panel/v1/border_radius".text = ''
        8
      '';

      # COSMIC Panel entries configuration
      "cosmic/com.system76.CosmicPanel/v1/entries".text = ''
        [
            "Panel",
        ]
      '';

      # COSMIC Theme Mode Configuration
      "cosmic/com.system76.CosmicTheme.Mode/v1/auto_switch".text = ''
        true
      '';

      "cosmic/com.system76.CosmicTheme.Mode/v1/is_dark".text = ''
        true
      '';

      # COSMIC Dark Theme Configuration
      "cosmic/com.system76.CosmicTheme.Dark/v1/accent".text = ''
        (
            red: 0.4941176470588235,
            green: 0.7843137254901961,
            blue: 0.9607843137254902,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/accent_button".text = ''
        (
            red: 0.4941176470588235,
            green: 0.7843137254901961,
            blue: 0.9607843137254902,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/background".text = ''
        (
            red: 0.06666666666666667,
            green: 0.06666666666666667,
            blue: 0.06666666666666667,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/button".text = ''
        (
            red: 0.16862745098039217,
            green: 0.16862745098039217,
            blue: 0.16862745098039217,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/destructive".text = ''
        (
            red: 0.9372549019607843,
            green: 0.3137254901960784,
            blue: 0.3137254901960784,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/destructive_button".text = ''
        (
            red: 0.9372549019607843,
            green: 0.3137254901960784,
            blue: 0.3137254901960784,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/link_button".text = ''
        (
            red: 0.4941176470588235,
            green: 0.7843137254901961,
            blue: 0.9607843137254902,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/icon_button".text = ''
        (
            red: 0.9372549019607843,
            green: 0.9372549019607843,
            blue: 0.9372549019607843,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/primary".text = ''
        (
            red: 0.13333333333333333,
            green: 0.13333333333333333,
            blue: 0.13333333333333333,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/secondary".text = ''
        (
            red: 0.20392156862745098,
            green: 0.20392156862745098,
            blue: 0.20392156862745098,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/success".text = ''
        (
            red: 0.5647058823529412,
            green: 0.7647058823529411,
            blue: 0.4745098039215686,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/text_button".text = ''
        (
            red: 0.9372549019607843,
            green: 0.9372549019607843,
            blue: 0.9372549019607843,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/warning".text = ''
        (
            red: 0.9568627450980393,
            green: 0.7019607843137254,
            blue: 0.3411764705882353,
            alpha: 1.0,
        )
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/warning_button".text = ''
        (
            red: 0.9568627450980393,
            green: 0.7019607843137254,
            blue: 0.3411764705882353,
            alpha: 1.0,
        )
      '';
    };
  };
}