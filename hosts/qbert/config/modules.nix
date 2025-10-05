{
  config,
  pkgs,
  user-settings,
  ...
}:
{

  users.default.enable = true;

  sys = {
    desktop-files = {
      enable = true;
      reboot-windows = true;

    };
    disable-stub-dns.enable = true;
    stylix-theme.wallpaperType = "personal";
    plymouth.backgroundType = "personal";
    timezone.enable = true;
  };

  # Desktop configuration - testing hash fix in custom COSMIC build
  desktops = {
    # gnome.enable = false;
    # cosmic.enable = false;
    tiling = {
      hyprland.enable = true;
    };
  };

  apps = {
    syncthing = {
      enable = true;
      host.qbert = true;
    };
    ollama = {
      enable = true;
      host.qbert = true;
    };
  };

  dev = {
    nix.enable = true;
    cachix.enable = true;
  };

  cli = {
    restic = {
      enable = true;
      folderName = "tower";
      backupPaths = [
        "/home/${user-settings.user.username}/.gnupg"
        "/home/${user-settings.user.username}/.kube"
        "/home/${user-settings.user.username}/.ssh"
        "/home/${user-settings.user.username}/.talos"
        "/home/${user-settings.user.username}/Desktop"
        "/home/${user-settings.user.username}/dev"
        "/home/${user-settings.user.username}/docker"
        "/home/${user-settings.user.username}/Documents"
        "/home/${user-settings.user.username}/Pictures"
      ];
      localBackup = {
        enable = true;
        path = "/run/media/${user-settings.user.username}/dk-data/Restic-backups";
        mountCheck.enable = true; # Enable prevalidation mount check
      };
      validation = {
        enable = true;
        schedule = "Sun *-*-* 23:00:00"; # Sunday 11 PM
        type = "read-data-subset";
        dataSubsetPercent = "10%";
      };
    };
  };

  suites = {
    ai.enable = true;
  };
}
