{ pkgs, user-settings, ... }:
{

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
  };

  home-manager.users."${user-settings.user.username}" = {
    # Home Manager Configuration

    # Additional environment variables for Wayland
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      GDK_BACKEND = "wayland";
      XDG_SESSION_TYPE = "wayland";
      WLR_NO_HARDWARE_CURSORS = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
