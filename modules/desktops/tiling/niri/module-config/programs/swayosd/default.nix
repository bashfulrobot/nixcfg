{ user-settings, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    services.swayosd = {
      enable = true;
      systemdTarget = "niri-session.target";
    };
  };
}