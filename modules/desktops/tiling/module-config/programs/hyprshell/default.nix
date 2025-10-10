{ user-settings, pkgs, inputs, config, ... }:

let
  buildTheme = pkgs.callPackage ../../../../../../lib/stylix-theme.nix { };
  styles = buildTheme.build {
    inherit (config.lib.stylix) colors;
    file = builtins.readFile ./styles.css;
  };
in
{
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

    # Custom CSS styling for hyprshell using stylix-theme library
    xdg.configFile."hyprshell/styles.css".text = styles;
  };
}