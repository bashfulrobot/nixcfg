{ user-settings, pkgs, secrets, config, lib, ... }:
let
  cfg = config.cli.restic;
  hostname = config.networking.hostName;
in
{
  options = {
    cli.restic = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Restic backup tool with autorestic configuration.";
      };

      folderName = lib.mkOption {
        type = lib.types.str;
        description = "Folder name within the shared bucket for this host's backups.";
      };

      backupPaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/home/${user-settings.user.username}" ];
        description = "List of paths to backup.";
      };

      excludePaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "node_modules"
          ".git"
          ".cache"
          "Cache"
          "cache"
          ".tmp"
          "tmp"
          "Trash"
          ".Trash"
          "Downloads"
          ".vscode"
          ".idea"
        ];
        description = "List of paths/patterns to exclude from backups.";
      };

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "0 2 * * *";
        description = "Cron schedule for automatic backups (default: 2 AM daily).";
      };

      retentionPolicy = lib.mkOption {
        type = lib.types.attrs;
        default = {
          keep-last = 10;
          keep-within = "30d";
        };
        description = "Retention policy for backups.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.restic
      unstable.autorestic
      unstable.backblaze-b2
    ];

    home-manager.users."${user-settings.user.username}" = {
      home.file.".autorestic.yml".text = ''
version: 2

backends:
  b2-${cfg.folderName}:
    type: b2
    path: 'ws-bups:${cfg.folderName}'
    env:
      B2_ACCOUNT_ID: ${secrets.restic.b2_account_id}
      B2_ACCOUNT_KEY: ${secrets.restic.b2_account_key}
      RESTIC_PASSWORD: ${secrets.restic.restic_password}

locations:
  ${cfg.folderName}-backup:
    from:
${lib.concatMapStringsSep "\n" (path: "      - ${path}") cfg.backupPaths}
    to:
      - b2-${cfg.folderName}
    cron: "${cfg.schedule}"
    forget: prune
    options:
      backup:
        exclude-file: /home/${user-settings.user.username}/.autorestic-exclude
      forget:
        keep-last: ${toString cfg.retentionPolicy.keep-last}
        keep-within: "${cfg.retentionPolicy.keep-within}"

global:
  forget:
    keep-last: ${toString cfg.retentionPolicy.keep-last}
    keep-within: "${cfg.retentionPolicy.keep-within}"
      '';

      home.file.".autorestic-exclude".text = lib.concatStringsSep "\n" cfg.excludePaths;

      # Create convenience scripts
      home.packages = with pkgs; [
        (writeShellScriptBin "restic-backup" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          echo "Backing up all configured paths..."
          autorestic backup -a
        '')

        (writeShellScriptBin "restic-restore" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          if [ -z "$1" ]; then
            echo "Usage: restic-restore <destination-path> [include-pattern]"
            echo "Example: restic-restore /tmp/restore-all                    # Restore everything"
            echo "Example: restic-restore /tmp/restore-docs Documents        # Restore only Documents folder"
            echo "Example: restic-restore /tmp/restore-ssh .ssh              # Restore only .ssh folder"
            echo ""
            echo "Available folders to restore:"
${lib.concatMapStringsSep "\n" (path: "            echo \"  - ${lib.last (lib.splitString "/" path)}\"") cfg.backupPaths}
            exit 1
          fi

          DESTINATION="$1"
          INCLUDE_PATTERN="$2"

          if [ -n "$INCLUDE_PATTERN" ]; then
            echo "Restoring files matching '$INCLUDE_PATTERN' to '$DESTINATION'..."
            autorestic restore -l ${cfg.folderName}-backup --to "$DESTINATION" --include "*$INCLUDE_PATTERN*"
          else
            echo "Restoring all files to '$DESTINATION'..."
            autorestic restore -l ${cfg.folderName}-backup --to "$DESTINATION"
          fi
        '')

        (writeShellScriptBin "restic-list-files" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          echo "Listing files in latest snapshot..."
          autorestic exec -l ${cfg.folderName}-backup -- ls latest
        '')

        (writeShellScriptBin "restic-status" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          echo "=== Autorestic Status ==="
          autorestic info | grep -v -E "(B2_ACCOUNT_|RESTIC_PASSWORD|account_id|account_key)"
          echo ""
          echo "=== Recent Snapshots ==="
          autorestic exec -l ${cfg.folderName}-backup -- snapshots --last 10
        '')

        (writeShellScriptBin "restic-init" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          autorestic check
          autorestic backup -a
        '')
      ];
    };

    # Systemd timer for automated backups
    systemd.user.services.autorestic-backup = {
      description = "Autorestic backup service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "autorestic-backup" ''
          cd /home/${user-settings.user.username}
          ${pkgs.unstable.autorestic}/bin/autorestic backup -a
        ''}";
        User = user-settings.user.username;
      };
    };

    systemd.user.timers.autorestic-backup = {
      description = "Autorestic backup timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}