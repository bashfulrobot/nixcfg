{ user-settings, pkgs, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    services.swayosd = {
        enable = true;
        package = pkgs.swayosd;
        topMargin = 0.9; # Position OSD towards bottom of screen
        stylePath = null; # Use default styling for now
      };
  };
}