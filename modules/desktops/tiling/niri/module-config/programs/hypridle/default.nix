{ user-settings, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "niri msg action power-off-monitors";
          before_sleep_cmd = "niri msg action power-off-monitors";
          lock_cmd = "swaylock -f";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "swaylock -f";
          }
          {
            timeout = 600;
            on-timeout = "niri msg action power-off-monitors";
            on-resume = "niri msg action power-on-monitors";
          }
        ];
      };
    };
  };
}