{ user-settings, pkgs, inputs, config, ... }: {
  # Home manager configuration with hyprshell module
  home-manager.users."${user-settings.user.username}" = {
    imports = [
      inputs.hyprshell.homeModules.hyprshell
    ];

    programs.hyprshell = {
      enable = true;

      settings = {
        windows = {
          enable = true;
          switch = {
            enable = true;
            modifier = "alt";
          };
        };
      };
    };

    # Custom CSS styling for hyprshell
    xdg.configFile."hyprshell/styles.css".text = ''
      :root {
        /* Border colors from Stylix */
        --border-color: #${config.lib.stylix.colors.base03};
        --border-color-active: #${config.lib.stylix.colors.base0D};

        /* Background colors from Stylix */
        --bg-color: #${config.lib.stylix.colors.base00};
        --bg-color-hover: #${config.lib.stylix.colors.base02};

        /* Border styling */
        --border-radius: 8px;
        --border-size: 1px;
        --border-style: solid;

        /* Text color from Stylix */
        --text-color: #${config.lib.stylix.colors.base05};

        /* Window padding */
        --window-padding: 2px;
      }
    '';
  };
}