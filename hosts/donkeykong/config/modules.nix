{
  config,
  lib,
  pkgs,
  user-settings,
  ...
}:
{

  users.default.enable = true;

  sys = {
    desktop-files = {
      enable = true;
      reboot-windows = false;

    };
    disable-stub-dns.enable = true;
    power.clamshell = true;
    stylix-theme.wallpaperType = "professional";
    plymouth.backgroundType = "professional";
    timezone.enable = true;
  };

  # Enable desktop environments
  desktops = {
    cosmic.enable = true;
    # gnome.enable = false;
  # tiling.hyprland.enable = false;
  };

  cli = {
    # only a subset of ai tools needed on this host.
    # not powerful enough for full suite.
    gemini-cli.enable = true;
    claude-code.enable = true;
    restic = {
      enable = true;
      folderName = "donkeykong";
      backupPaths = [
        "/home/${user-settings.user.username}/.gnupg"
        "/home/${user-settings.user.username}/.ssh"
        "/home/${user-settings.user.username}/Desktop"
        "/home/${user-settings.user.username}/dev"
        "/home/${user-settings.user.username}/docker"
        "/home/${user-settings.user.username}/Documents"
        "/home/${user-settings.user.username}/Pictures"
      ];
    };
  };

  # apps.syncthing = {
  #   enable = true;
  #   host.donkeykong = true;
  # };
}
