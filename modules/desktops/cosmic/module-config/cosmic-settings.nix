{
  user-settings,
  config,
  lib,
  ...
}:
let
  wallpaperPath = "${user-settings.user.home}/Pictures/wallpapers/${user-settings.theme.personal-wallpaper}";
in
{
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

      # Wallpaper configuration for COSMIC Settings
      "cosmic/com.system76.CosmicSettings.Wallpaper/v1/custom-images".text = wallpaperPath;

      # Theme mode configuration
      "cosmic/com.system76.CosmicTheme.Mode/v1/is_dark".text = ''
        true
      '';

      # Dark theme color configurations
      "cosmic/com.system76.CosmicTheme.Dark.Builder/v1/accent".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/accent".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/accent_button".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/background".text = ''
        (srgb: (red: 0.156863, green: 0.156863, blue: 0.156863, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/button".text = ''
        (srgb: (red: 0.235294, green: 0.235294, blue: 0.235294, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/destructive".text = ''
        (srgb: (red: 0.8, green: 0.141176, blue: 0.141176, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/destructive_button".text = ''
        (srgb: (red: 0.8, green: 0.141176, blue: 0.141176, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/link_button".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/icon_button".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/primary".text = ''
        (srgb: (red: 0.921569, green: 0.858824, blue: 0.698039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/secondary".text = ''
        (srgb: (red: 0.658824, green: 0.600000, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/success".text = ''
        (srgb: (red: 0.458824, green: 0.678431, blue: 0.498039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/text_button".text = ''
        (srgb: (red: 0.921569, green: 0.858824, blue: 0.698039, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/warning".text = ''
        (srgb: (red: 0.980392, green: 0.721569, blue: 0.423529, alpha: 1.0))
      '';

      "cosmic/com.system76.CosmicTheme.Dark/v1/warning_button".text = ''
        (srgb: (red: 0.980392, green: 0.721569, blue: 0.423529, alpha: 1.0))
      '';

      # Time applet configuration - enable 24-hour military time
      "cosmic/com.system76.CosmicAppletTime/v1/military_time".text = ''
        true
      '';
    } // lib.optionalAttrs (!config.sys.power.enable) {
      # Desktop-only power settings (not for laptops)
      xdg.configFile."cosmic/com.system76.CosmicIdle/v1/suspend_on_ac_time".text = ''
        Some(7200000)
      '';
    };
  };
}