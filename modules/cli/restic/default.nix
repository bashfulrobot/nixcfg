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
        default = [
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
          keep-daily = 7;
          keep-weekly = 4;
          keep-monthly = 12;
          keep-yearly = 2;
        };
        description = "Retention policy for backups.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      restic
      autorestic
    ];

    home-manager.users."${user-settings.user.username}" = {
      home.file.".autorestic.yml".text = ''
        version: 2

        backends:
          b2-${hostname}:
            type: b2
            path: 'ws-bups:${cfg.folderName}'
            env:
              B2_ACCOUNT_ID: ${secrets.restic.b2_account_id}
              B2_ACCOUNT_KEY: ${secrets.restic.b2_account_key}
              RESTIC_PASSWORD: ${secrets.restic.restic_password}

        locations:
          ${hostname}-home:
            from: ${lib.concatStringsSep " " cfg.backupPaths}
            to:
              - b2-${hostname}
            cron: "${cfg.schedule}"
            forget:
              keep-daily: ${toString cfg.retentionPolicy.keep-daily}
              keep-weekly: ${toString cfg.retentionPolicy.keep-weekly}
              keep-monthly: ${toString cfg.retentionPolicy.keep-monthly}
              keep-yearly: ${toString cfg.retentionPolicy.keep-yearly}
            options:
              backup:
                exclude-file: /home/${user-settings.user.username}/.autorestic-exclude

        global:
          forget:
            keep-daily: ${toString cfg.retentionPolicy.keep-daily}
            keep-weekly: ${toString cfg.retentionPolicy.keep-weekly}
            keep-monthly: ${toString cfg.retentionPolicy.keep-monthly}
            keep-yearly: ${toString cfg.retentionPolicy.keep-yearly}
      '';

      home.file.".autorestic-exclude".text = lib.concatStringsSep "\n" cfg.excludePaths;

      # Create convenience scripts
      home.packages = with pkgs; [
        (writeShellScriptBin "restic-backup" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          autorestic backup -a
        '')

        (writeShellScriptBin "restic-restore" ''
          #!/bin/sh
          if [ -z "$1" ]; then
            echo "Usage: restic-restore <destination-path>"
            echo "Example: restic-restore /tmp/restore"
            exit 1
          fi
          cd /home/${user-settings.user.username}
          autorestic exec -a -- restore latest --target "$1"
        '')

        (writeShellScriptBin "restic-status" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}
          echo "=== Autorestic Status ==="
          autorestic info
          echo ""
          echo "=== Recent Snapshots ==="
          autorestic exec -a -- snapshots --last 10
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
          ${pkgs.autorestic}/bin/autorestic backup -a
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