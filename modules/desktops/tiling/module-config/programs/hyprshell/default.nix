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
        /* Remove outer border by setting transparent border */
        --border-color: rgba(0, 0, 0, 0);
        --border-color-active: #${config.lib.stylix.colors.base0D};

        /* Background colors from Stylix */
        --bg-color: #${config.lib.stylix.colors.base00};
        --bg-color-hover: #${config.lib.stylix.colors.base02};

        /* Border styling - set size to 0 to remove outer border */
        --border-radius: 8px;
        --border-size: 0px;
        --border-style: solid;

        /* Text color from Stylix */
        --text-color: #${config.lib.stylix.colors.base05};

        /* Window padding */
        --window-padding: 2px;
      }
    '';
  };
}