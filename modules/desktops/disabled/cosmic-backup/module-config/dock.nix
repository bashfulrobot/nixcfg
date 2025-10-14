{
  user-settings,
  config,
  lib,
  ...
}:

{
  # COSMIC Dock Configuration
  home-manager.users."${user-settings.user.username}" = {
    xdg.configFile = {
      # Dock Configuration
      "cosmic/com.system76.CosmicPanel.Dock/v1/plugins_wings" = {
        text = ''
          Some(([], []))
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/plugins_center" = {
        text = ''
          Some([
              "com.system76.CosmicAppList",
              "com.system76.CosmicAppletMinimize",
          ])
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/opacity" = {
        text = ''
          0.0
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/size_wings" = {
        text = ''
          None
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/expand_to_edges" = {
        text = ''
          false
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/size" = {
        text = ''
          S
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/spacing" = {
        text = ''
          4
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/padding" = {
        text = ''
          0
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/autohide" = {
        text = ''
          Some((
              wait_time: 1000,
              transition_time: 200,
              handle_size: 4,
          ))
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/anchor_gap" = {
        text = ''
          true
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/keyboard_interactivity" = {
        text = ''
          OnDemand
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/border_radius" = {
        text = ''
          160
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/margin" = {
        text = ''
          4
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/size_center" = {
        text = ''
          None
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/background" = {
        text = ''
          ThemeDefault
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/layer" = {
        text = ''
          Top
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/autohover_delay_ms" = {
        text = ''
          Some(500)
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/output" = {
        text = ''
          All
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/exclusive_zone" = {
        text = ''
          false
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/name" = {
        text = ''
          "Dock"
        '';
        force = true;
      };

      "cosmic/com.system76.CosmicPanel.Dock/v1/anchor" = {
        text = ''
          Bottom
        '';
        force = true;
      };
    };
  };
}