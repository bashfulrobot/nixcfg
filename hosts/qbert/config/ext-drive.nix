{ user-settings, ... }:
{
  # External USB drive configuration for qbert
  # dk-data drive: 1.4TB ext4 drive for backups and storage

  fileSystems."/run/media/dustin/dk-data" = {
    device = "/dev/disk/by-uuid/418fdd41-49fa-4c05-ac19-1d2615c93234";
    fsType = "ext4";
    options = [
      "defaults"
      "user"
      "rw"
      "exec"
      "auto"
      "nofail"  # Don't fail boot if drive is not present
    ];
    # Don't check filesystem on boot
    noCheck = true;
  };

  # Create mount point directory with proper ownership
  systemd.tmpfiles.rules = [
    "d /run/media/dustin/dk-data 0755 ${user-settings.user.username} users -"
    "d /run/media/dustin/dk-data/Restic-backups 0755 ${user-settings.user.username} users -"
    "d /run/media/dustin/dk-data/Restic-backups/tower 0755 ${user-settings.user.username} users -"
  ];

  # Enable services for USB management
  services.udisks2.enable = true;

  # Ensure user can access external drives
  users.users.${user-settings.user.username}.extraGroups = [ "storage" ];
}