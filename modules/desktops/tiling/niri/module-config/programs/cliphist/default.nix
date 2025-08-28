{ user-settings, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    services.cliphist = {
      enable = true;
      systemdTargets = [ "niri-session.target" ];
    };
  };
}