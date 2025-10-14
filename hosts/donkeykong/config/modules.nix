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
    # gnome.enable = false;
    cosmic.enable = true;
    tiling = {
      hyprland.enable = false;
    };
  };

  cli = {
    # only a subset of ai tools needed on this host.
    # not powerful enough for full suite.
    gemini-cli.enable = true;
    claude-code.enable = true;

    rclone = {
      enable = true;
      enableSync = false;  # Laptop - don't sync to avoid conflicts
      enableMount = true;  # Use mount for safe access
      mountPath = "/home/${user-settings.user.username}/GoogleDrive";
      mountCacheMode = "full";
      mountCacheSize = "500M"; # Smaller cache for laptop
    };

    restic = {
      enable = true;
      folderName = "donkeykong";
      backupPaths = [
        "/home/${user-settings.user.username}/.gnupg"
        "/home/${user-settings.user.username}/.ssh"
        "/home/${user-settings.user.username}/Desktop"
        "/home/${user-settings.user.username}/dev"
        "/home/${user-settings.user.username}/Documents"
        "/home/${user-settings.user.username}/Pictures"
      ];
      validation = {
        enable = true;
        schedule = "Sun *-*-* 23:30:00"; # Sunday 11:30 PM (offset from qbert)
        type = "basic"; # Lighter validation for laptop
        # No dataSubsetPercent needed for basic validation
      };
    };
  };

  # apps.syncthing = {
  #   enable = true;
  #   host.donkeykong = true;
  # };

  suites = {
    ai.enable = true;
  };
}
