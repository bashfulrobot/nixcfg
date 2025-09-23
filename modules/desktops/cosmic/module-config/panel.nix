{
  user-settings,
  config,
  lib,
  ...
}:

{
  # COSMIC Panel Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # Main Panel Configuration
      "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings" = {
        text = ''
          Some(([
              "com.system76.CosmicAppList",
          ], [
              "com.system76.CosmicAppletAudio",
              "com.system76.CosmicAppletBluetooth",
              "com.system76.CosmicAppletNetwork",
              "com.system76.CosmicAppletBattery",
              "com.system76.CosmicAppletNotifications",
              "com.system76.CosmicAppletPower",
          ]))
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center" = {
        text = ''
          Some([
              "com.system76.CosmicAppletTime",
          ])
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/size_wings" = {
        text = ''
          None
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/expand_to_edges" = {
        text = ''
          false
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/size" = {
        text = ''
          M
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/anchor_gap" = {
        text = ''
          false
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/keyboard_interactivity" = {
        text = ''
          OnDemand
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/size_center" = {
        text = ''
          None
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/background" = {
        text = ''
          ThemeDefault
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/layer" = {
        text = ''
          Top
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/output" = {
        text = ''
          All
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/name" = {
        text = ''
          "Panel"
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/anchor" = {
        text = ''
          Bottom
        '';
        force = true;
      };


      # Settings that match current system values but aren't in cosmic.nix
      "cosmic/com.system76.CosmicPanel.Panel/v1/opacity" = {
        text = ''
          0.50
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/spacing" = {
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

      "cosmic/com.system76.CosmicPanel.Panel/v1/border_radius" = {
        text = ''
          160
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Panel/v1/margin" = {
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

      "cosmic/com.system76.CosmicPanel.Panel/v1/exclusive_zone" = {
        text = ''
          false
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel/v1/entries" = {
        text = ''
          [
              "Panel",
          ]
        '';
        force = true;
      };

      # Applet Settings
      "cosmic/com.system76.CosmicAppletAudio/v1/show_media_controls_in_top_panel" = {
        text = ''
          true
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicAppletTime/v1/military_time" = {
        text = ''
          true
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicAppletTime/v1/first_day_of_week" = {
        text = ''
          6
        '';
        force = true;
      };
    };
  };
}