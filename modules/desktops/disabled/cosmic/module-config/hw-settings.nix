{
  user-settings,
  config,
  lib,
  ...
}:
{
  # COSMIC Hardware and Power Management Configuration
  home-manager.users."${user-settings.user.username}" = lib.optionalAttrs (!config.sys.power.enable) {
    # Desktop-only power settings (not for laptops)
    xdg.configFile."cosmic/com.system76.CosmicIdle/v1/suspend_on_ac_time".text = ''
      Some(7200000)
    '';
  };
}