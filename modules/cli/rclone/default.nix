{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  ...
}:
let
  cfg = config.cli.rclone;

  # Rclone script packages using standard pattern
  rcloneScripts = with pkgs; [
    (writeShellScriptBin "kong-sync" (builtins.readFile ./scripts/kong-sync.sh))
    (writeShellScriptBin "kong-first-sync" (builtins.readFile ./scripts/kong-first-sync.sh))
    (writeShellScriptBin "rclone-auth" (builtins.readFile ./scripts/rclone-auth.sh))
  ] ++ lib.optionals cfg.enableMount [
    (writeShellScriptBin "gdrive-mount" ''
      #!/usr/bin/env bash
      # Mount Google Drive manually
      systemctl --user start rclone-mount.service
      echo "Google Drive mounting at ${cfg.mountPath}"
      echo "Check status: systemctl --user status rclone-mount"
    '')
    (writeShellScriptBin "gdrive-unmount" ''
      #!/usr/bin/env bash
      # Unmount Google Drive safely
      systemctl --user stop rclone-mount.service
      echo "Google Drive unmounted from ${cfg.mountPath}"
    '')
    (writeShellScriptBin "gdrive-status" ''
      #!/usr/bin/env bash
      # Check Google Drive mount status
      echo "=== Google Drive Mount Status ==="
      systemctl --user status rclone-mount.service --no-pager
      echo ""
      echo "=== Mount Point ==="
      if mountpoint -q "${cfg.mountPath}"; then
        echo "✓ ${cfg.mountPath} is mounted"
        df -h "${cfg.mountPath}"
      else
        echo "✗ ${cfg.mountPath} is not mounted"
      fi
    '')
  ];

in
{
  options = {
    cli.rclone = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable rclone cloud storage tool.";
      };

      enableSync = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable bidirectional Kong folder sync (recommended for primary desktop).";
      };

      enableMount = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Google Drive FUSE mount (recommended for laptops/secondary devices).";
      };

      mountPath = lib.mkOption {
        type = lib.types.str;
        default = "${user-settings.user.home}/GoogleDrive";
        description = "Local mount point for Google Drive.";
      };

      mountCacheMode = lib.mkOption {
        type = lib.types.enum ["off" "minimal" "writes" "full"];
        default = "full";
        description = "VFS cache mode: off (no cache), minimal (metadata only), writes (cache writes), full (cache everything).";
      };

      mountCacheSize = lib.mkOption {
        type = lib.types.str;
        default = "1G";
        description = "Maximum size for VFS cache (e.g., '1G', '500M').";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure FUSE is available for mounting
    programs.fuse.userAllowOther = lib.mkIf cfg.enableMount true;

    environment.systemPackages = with pkgs; [
      rclone
      libnotify   # for notify-send
    ] ++ lib.optionals cfg.enableMount [ fuse ] ++ rcloneScripts;

    home-manager.users."${user-settings.user.username}" = lib.mkMerge [
      # Base configuration
      {
        # Create writable rclone config using activation script
        # This preserves OAuth tokens while keeping secrets in NixOS
        home.activation.rcloneConfig = lib.mkAfter ''
          RCLONE_CONFIG_DIR="/home/${user-settings.user.username}/.config/rclone"
          RCLONE_CONFIG="$RCLONE_CONFIG_DIR/rclone.conf"

          # Create directory
          $DRY_RUN_CMD mkdir -p "$RCLONE_CONFIG_DIR"

          # Only create initial config if it doesn't exist (preserves tokens)
          if [ ! -f "$RCLONE_CONFIG" ]; then
            $DRY_RUN_CMD cat > "$RCLONE_CONFIG" << 'EOF'
[gdrive]
type = drive
scope = drive
client_id = ${secrets.rclone.google_drive.client_id}
client_secret = ${secrets.rclone.google_drive.client_secret}
# OAuth tokens will be added here automatically after authentication
EOF
            $DRY_RUN_CMD chmod 600 "$RCLONE_CONFIG"
            echo "Created writable rclone config with NixOS secrets"
          else
            echo "Rclone config exists, preserving OAuth tokens"
          fi
        '';
      }

      # Mount configuration (only if mount is enabled)
      (lib.mkIf cfg.enableMount {
        systemd.user.services.rclone-mount = {
          Unit = {
            Description = "Mount Google Drive via rclone";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };

          Service = {
            Type = "notify";
            ExecStartPre = [
              # Create mount directory
              "${pkgs.coreutils}/bin/mkdir -p ${cfg.mountPath}"
              # Ensure we can access Google Drive
              "${pkgs.rclone}/bin/rclone lsd gdrive:"
            ];
            ExecStart = "${pkgs.writeShellScript "rclone-mount" ''
              exec ${pkgs.rclone}/bin/rclone mount gdrive: ${cfg.mountPath} --vfs-cache-mode ${cfg.mountCacheMode} --vfs-cache-max-size ${cfg.mountCacheSize} --vfs-cache-max-age 24h --dir-cache-time 24h --poll-interval 1m --cache-dir ${user-settings.user.home}/.cache/rclone --allow-other --default-permissions --umask 002 --uid $(id -u) --gid $(id -g) --log-level INFO --log-file ${user-settings.user.home}/.local/share/rclone/mount.log
            ''}";
            ExecStop = "${pkgs.util-linux}/bin/fusermount -u ${cfg.mountPath}";
            Restart = "on-failure";
            RestartSec = "10s";
            KillMode = "mixed";
            KillSignal = "SIGINT";
            TimeoutStopSec = "10s";
          };

          Install = {
            WantedBy = [ "default.target" ];
          };
        };

        # Ensure mount directory exists
        home.activation.createMountDir = lib.mkAfter ''
          $DRY_RUN_CMD mkdir -p ${cfg.mountPath}
        '';
      })

      # Sync configuration (only if sync is enabled)
      (lib.mkIf cfg.enableSync {
        systemd.user.services.kong-sync = {
          Unit = {
            Description = "Bidirectional sync of Kong folder with Google Drive root";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };

          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.writeShellScript "kong-sync-service" ''
              #!/usr/bin/env bash
              export PATH="${lib.makeBinPath [pkgs.rclone pkgs.libnotify]}:$PATH"
              exec kong-sync
            ''}";
            # Prevent running if another instance is active
            Restart = "on-failure";
            RestartSec = "5m";
          };
        };

        systemd.user.timers.kong-sync = {
          Unit = {
            Description = "Run Kong folder sync every 15 minutes";
          };

          Timer = {
            OnCalendar = "*:0/15";  # Every 15 minutes
            Persistent = true;
          };

          Install = {
            WantedBy = [ "timers.target" ];
          };
        };
      })
    ];
  };
}