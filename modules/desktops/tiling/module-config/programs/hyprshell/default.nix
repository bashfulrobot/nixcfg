{ user-settings, lib, config, inputs, ... }:
let cfg = config.desktops.tiling.hyprland;
in {
  config = lib.mkIf cfg.enable {
    
    home-manager.users."${user-settings.user.username}" = {
      imports = [ inputs.hyprshell.homeModules.hyprshell ];
      
      programs.hyprshell = {
        enable = true;
        systemd = {
          enable = true;
          args = "-v"; # verbose logging
        };
        settings = {
          # Hyprshell configuration
          windows = {
            overview = {
              key = "super_l";
              modifier = [];
            };
          };
          # Add more configuration as needed
          # See: https://github.com/H3rmt/hyprshell for configuration options
        };
        style = ''
          /* Custom CSS styles for hyprshell */
          /* Add your styling here */
        '';
      };
    };
    
  };
}