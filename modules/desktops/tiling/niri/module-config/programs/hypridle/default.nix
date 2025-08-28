{ user-settings, pkgs, lib, ... }:

{
  home-manager.users."${user-settings.user.username}" = {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          # Avoid starting multiple instances of hyprlock.
          # Then show the startup reminder after the lock has
          # ended.
          lock_cmd = lib.mkForce "(pidof hyprlock || ${pkgs.hyprlock}); startup-reminder";

          before_sleep_cmd = lib.mkForce "loginctl lock-session; sleep 1;";
          # After waking up, sometimes the timeout listener for shutting off the
          # screens will shut them off again. Wait for that to settle…
          after_sleep_cmd = lib.mkForce "sleep 0.5; niri msg action power-on-monitors";
        };

        listener = [
          # Monitor power save
          {
            timeout = 720; # 12 min
            on-timeout = "niri msg action power-off-monitors";
            on-resume = "niri msg action power-on-monitors";
          }

          # Dim screen
          {
            timeout = 300; # 5 min
            on-timeout = "${pkgs.brightnessctl} -s set 10";
            on-resume = "${pkgs.brightnessctl} -r";
          }
          # Dim keyboard
          {
            timeout = 300; # 5 min
            on-timeout = "${pkgs.brightnessctl} -sd rgb:kbd_backlight set 0";
            on-resume = "${pkgs.brightnessctl} -rd rgb:kbd_backlight";
          }

          {
            timeout = 600; # 10 min
            on-timeout = "loginctl lock-session";
          }
        ];
      };
    };
  };
}
