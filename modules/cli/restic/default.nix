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

      localBackup = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable local backup target in addition to cloud backup.";
        };

        path = lib.mkOption {
          type = lib.types.str;
          description = "Local path for backup storage. Can be any accessible path: USB drive, network mount, second drive, etc.";
          example = "/run/media/${user-settings.user.username}/dk-data/Restic-backups";
        };
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
      home.file.".autorestic.yml".text =
        let
          # Build list of target backends
          targets = [ "b2-${cfg.folderName}" ] ++ lib.optional cfg.localBackup.enable "local-${cfg.folderName}";

          # Generate target list for YAML
          targetsList = lib.concatMapStringsSep "\n" (target: "      - ${target}") targets;
        in ''
version: 2

backends:
  b2-${cfg.folderName}:
    type: b2
    path: 'ws-bups:${cfg.folderName}'
    env:
      B2_ACCOUNT_ID: ${secrets.restic.b2_account_id}
      B2_ACCOUNT_KEY: ${secrets.restic.b2_account_key}
      RESTIC_PASSWORD: ${secrets.restic.restic_password}${lib.optionalString cfg.localBackup.enable "\n  local-${cfg.folderName}:\n    type: local\n    path: '${cfg.localBackup.path}/${cfg.folderName}'\n    env:\n      RESTIC_PASSWORD: ${secrets.restic.restic_password}"}
locations:
  ${cfg.folderName}-backup:
    from:
${lib.concatMapStringsSep "\n" (path: "      - ${path}") cfg.backupPaths}
    to:
${targetsList}
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
            echo "Usage: restic-restore <destination-path> [include-pattern] [backend]"
            echo "Example: restic-restore /tmp/restore-all                           # Restore everything from cloud"
            echo "Example: restic-restore /tmp/restore-docs Documents               # Restore only Documents folder"
            echo "Example: restic-restore /tmp/restore-ssh .ssh                     # Restore only .ssh folder"${lib.optionalString cfg.localBackup.enable ''
            echo "Example: restic-restore /tmp/restore-all \"\" local                # Restore from local backup"
            echo "Example: restic-restore /tmp/restore-docs Documents local        # Restore Documents from local backup"''}
            echo ""
            echo "=== Current Configuration ==="
            echo "Location: ${cfg.folderName}-backup"
            echo "Available backends:"
            autorestic info | grep -A 50 "Backend:" | grep "Type\|Path" | sed 's/^/  /'
            echo ""
            echo "Available folders to restore:"
${lib.concatMapStringsSep "\n" (path: "            echo \"  - ${lib.last (lib.splitString "/" path)}\"") cfg.backupPaths}
            exit 1
          fi

          DESTINATION="$1"
          INCLUDE_PATTERN="$2"
          BACKEND="''${3:-cloud}"

          # Select backend
          if [ "$BACKEND" = "local" ]${lib.optionalString cfg.localBackup.enable '' && [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]''}; then
            BACKEND_FLAG="--from local-${cfg.folderName}"
            echo "Restoring from local backup..."
          else
            BACKEND_FLAG="--from b2-${cfg.folderName}"
            echo "Restoring from cloud backup..."
          fi

          if [ -n "$INCLUDE_PATTERN" ]; then
            echo "Restoring files matching '$INCLUDE_PATTERN' to '$DESTINATION'..."
            autorestic restore -l ${cfg.folderName}-backup --to "$DESTINATION" $BACKEND_FLAG --include "*$INCLUDE_PATTERN*"
          else
            echo "Restoring all files to '$DESTINATION'..."
            autorestic restore -l ${cfg.folderName}-backup --to "$DESTINATION" $BACKEND_FLAG
          fi
        '')

        (writeShellScriptBin "restic-list-files" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          BACKEND="''${1:-cloud}"

          if [ "$BACKEND" = "local" ]${lib.optionalString cfg.localBackup.enable '' && [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]''}; then
            echo "Listing files in latest local snapshot..."
            autorestic exec -b local-${cfg.folderName} -- ls latest
          elif [ "$BACKEND" = "cloud" ]; then
            echo "Listing files in latest cloud snapshot..."
            autorestic exec -b b2-${cfg.folderName} -- ls latest
          else
            echo "Usage: restic-list-files [backend]"
            echo ""
            echo "=== Current Configuration ==="
            echo "Location: ${cfg.folderName}-backup"
            echo "Available backends:"
            autorestic info | grep -A 50 "Backend:" | grep "Type\|Path" | sed 's/^/  /'
          fi
        '')

        (writeShellScriptBin "restic-status" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          echo "=== Autorestic Configuration ==="
          autorestic info | grep -v -E "(B2_ACCOUNT_|RESTIC_PASSWORD|account_id|account_key)"
          echo ""
          echo "=== Cloud Backup Status ==="
          autorestic exec -b b2-${cfg.folderName} -- snapshots --last 5${lib.optionalString cfg.localBackup.enable ''
          echo ""
          echo "=== Local Backup Status ==="
          if [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]; then
            autorestic exec -b local-${cfg.folderName} -- snapshots --last 5
          else
            echo "Local backup directory not accessible: ${cfg.localBackup.path}/${cfg.folderName}"
          fi''}
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