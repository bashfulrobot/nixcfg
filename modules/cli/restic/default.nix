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
      unstable.gum
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

          gum style --foreground 212 --border-foreground 212 --border double --align center --width 50 --margin "1 2" --padding "2 4" \
            "🔄 Restic Backup Tool" "Starting backup process..."

          gum spin --spinner dot --title "Preparing backup..." -- sleep 1

          echo ""
          gum style --foreground 156 "📂 Backup paths:"
          ${lib.concatMapStringsSep "\n" (path: "          echo \"  • ${path}\"") cfg.backupPaths}

          echo ""
          if gum confirm "Proceed with backup?"; then
            gum style --foreground 226 "🚀 Starting backup process..."
            echo ""
            gum spin --spinner globe --title "Backing up files..." -- autorestic backup -a
            echo ""
            gum style --foreground 46 --bold "✅ Backup completed successfully!"
          else
            gum style --foreground 208 "❌ Backup cancelled"
            exit 1
          fi
        '')

        (writeShellScriptBin "restic-restore" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}

          gum style --foreground 75 --border-foreground 75 --border double --align center --width 50 --margin "1 2" --padding "2 4" \
            "🔄 Restic Restore Tool" "Interactive backup restoration"

          if [ -z "$1" ]; then
            gum style --foreground 208 "📋 Interactive Restore Mode"
            echo ""

            # Select destination path
            gum style --foreground 156 "📁 Choose destination method:"
            DEST_METHOD=$(gum choose "Browse for directory" "Type custom path")

            if [ "$DEST_METHOD" = "Browse for directory" ]; then
              gum style --foreground 156 "📂 Navigate to destination directory:"
              DESTINATION=$(gum file --directory --height 10)
            else
              gum style --foreground 156 "📁 Enter destination path for restore:"
              DESTINATION=$(gum input --placeholder "/tmp/restore-data" --prompt "Destination: ")
            fi

            if [ -z "$DESTINATION" ]; then
              gum style --foreground 196 "❌ No destination specified. Exiting."
              exit 1
            fi

            # Show available folders
            echo ""
            gum style --foreground 156 "📂 Available folders to restore:"
${lib.concatMapStringsSep "\n" (path: "            echo \"  • ${lib.last (lib.splitString "/" path)}\"") cfg.backupPaths}

            echo ""
            gum style --foreground 156 "🔍 Add file patterns to filter (one at a time, empty to finish):"
            PATTERNS=""
            while true; do
              PATTERN=$(gum input --placeholder "Documents, .ssh, etc. (empty to finish)" --prompt "Pattern: ")
              if [ -z "$PATTERN" ]; then
                break
              fi
              if [ -z "$PATTERNS" ]; then
                PATTERNS="$PATTERN"
              else
                PATTERNS="$PATTERNS,$PATTERN"
              fi
              gum style --foreground 46 "✅ Added: $PATTERN"
            done
            INCLUDE_PATTERN="$PATTERNS"

            # Select backend
            echo ""
            gum style --foreground 156 "🏗️ Select backup source:"
            BACKEND=$(gum choose "cloud" ${lib.optionalString cfg.localBackup.enable "\"local\""})
          else
            DESTINATION="$1"
            INCLUDE_PATTERN="$2"
            BACKEND="''${3:-cloud}"
          fi

          echo ""
          gum style --foreground 226 "Configuration Summary:"
          echo "  📁 Destination: $DESTINATION"
          echo "  🔍 Pattern: ''${INCLUDE_PATTERN:-\"All files\"}"
          echo "  🏗️ Source: $BACKEND"

          echo ""
          if ! gum confirm "Proceed with restore?"; then
            gum style --foreground 208 "❌ Restore cancelled"
            exit 1
          fi

          # Select backend
          if [ "$BACKEND" = "local" ]${lib.optionalString cfg.localBackup.enable '' && [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]''}; then
            BACKEND_FLAG="--from local-${cfg.folderName}"
            gum style --foreground 75 "📂 Restoring from local backup..."
          else
            BACKEND_FLAG="--from b2-${cfg.folderName}"
            gum style --foreground 75 "☁️ Restoring from cloud backup..."
          fi

          echo ""
          if [ -n "$INCLUDE_PATTERN" ]; then
            # Handle multiple patterns (comma-separated)
            if echo "$INCLUDE_PATTERN" | grep -q ","; then
              gum style --foreground 156 "🔍 Processing multiple patterns..."
              # Convert comma-separated patterns to multiple --include flags
              INCLUDE_FLAGS=""
              IFS=','
              for pattern in $INCLUDE_PATTERN; do
                pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # Trim whitespace
                INCLUDE_FLAGS="$INCLUDE_FLAGS --include *$pattern*"
              done
              unset IFS
              gum spin --spinner globe --title "Restoring files matching multiple patterns..." -- \
                autorestic restore -l ${cfg.folderName}-backup --to "$DESTINATION" $BACKEND_FLAG $INCLUDE_FLAGS
            else
              gum spin --spinner globe --title "Restoring files matching '$INCLUDE_PATTERN'..." -- \
                autorestic restore -l ${cfg.folderName}-backup --to "$DESTINATION" $BACKEND_FLAG --include "*$INCLUDE_PATTERN*"
            fi
          else
            gum spin --spinner globe --title "Restoring all files..." -- \
              autorestic restore -l ${cfg.folderName}-backup --to "$DESTINATION" $BACKEND_FLAG
          fi

          echo ""
          gum style --foreground 46 --bold "✅ Restore completed successfully!"
          gum style --foreground 156 "📁 Files restored to: $DESTINATION"
        '')

        (writeShellScriptBin "restic-list-files" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}

          gum style --foreground 33 --border-foreground 33 --border double --align center --width 50 --margin "1 2" --padding "2 4" \
            "📋 Restic File Listing" "Browse backup contents"

          if [ -z "$1" ]; then
            gum style --foreground 156 "🏗️ Select backup source to browse:"
            BACKEND=$(gum choose "cloud" ${lib.optionalString cfg.localBackup.enable "\"local\""})
          else
            BACKEND="$1"
          fi

          echo ""
          gum style --foreground 226 "📁 Listing files from $BACKEND backup..."

          if [ "$BACKEND" = "local" ]${lib.optionalString cfg.localBackup.enable '' && [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]''}; then
            echo ""
            gum spin --spinner dot --title "Fetching local snapshot contents..." -- sleep 1
            gum style --foreground 75 "📂 Files in latest local snapshot:"
            echo ""
            autorestic exec -b local-${cfg.folderName} -- ls latest | gum format
          elif [ "$BACKEND" = "cloud" ]; then
            echo ""
            gum spin --spinner dot --title "Fetching cloud snapshot contents..." -- sleep 1
            gum style --foreground 75 "☁️ Files in latest cloud snapshot:"
            echo ""
            autorestic exec -b b2-${cfg.folderName} -- ls latest | gum format
          else
            gum style --foreground 196 "❌ Invalid backend specified"
            echo ""
            gum style --foreground 156 "Available backends:"
            autorestic info | grep -A 50 "Backend:" | grep "Type\|Path" | sed 's/^/  /' | gum format
          fi
        '')

        (writeShellScriptBin "restic-status" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}

          gum style --foreground 51 --border-foreground 51 --border double --align center --width 60 --margin "1 2" --padding "2 4" \
            "📊 Restic Status Dashboard" "Backup system overview"

          echo ""
          gum style --foreground 156 --bold "🔧 Configuration Information"
          echo ""
          gum spin --spinner dot --title "Loading configuration..." -- sleep 1
          autorestic info | grep -v -E "(B2_ACCOUNT_|RESTIC_PASSWORD|account_id|account_key)" | gum format

          echo ""
          gum style --foreground 156 --bold "☁️ Cloud Backup Status"
          echo ""
          gum spin --spinner globe --title "Fetching cloud snapshots..." -- sleep 1
          autorestic exec -b b2-${cfg.folderName} -- snapshots --last 5 | gum format

          ${lib.optionalString cfg.localBackup.enable ''
          echo ""
          gum style --foreground 156 --bold "📂 Local Backup Status"
          echo ""
          if [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]; then
            gum spin --spinner dot --title "Fetching local snapshots..." -- sleep 1
            autorestic exec -b local-${cfg.folderName} -- snapshots --last 5 | gum format
          else
            gum style --foreground 196 "❌ Local backup directory not accessible:"
            echo "   ${cfg.localBackup.path}/${cfg.folderName}"
          fi''}

          echo ""
          gum style --foreground 46 --bold "✅ Status check completed!"
        '')

        (writeShellScriptBin "restic-init" ''
          #!/bin/sh
          cd /home/${user-settings.user.username}

          gum style --foreground 201 --border-foreground 201 --border double --align center --width 60 --margin "1 2" --padding "2 4" \
            "🚀 Restic Initialization" "Setup and first backup"

          echo ""
          gum style --foreground 156 "This will initialize your backup repositories and perform the first backup."
          echo ""

          if ! gum confirm "Initialize backup system?"; then
            gum style --foreground 208 "❌ Initialization cancelled"
            exit 1
          fi

          echo ""
          gum style --foreground 226 --bold "🔍 Step 1: Checking repository health"
          echo ""
          if gum spin --spinner dot --title "Checking repositories..." -- autorestic check; then
            gum style --foreground 46 "✅ Repository check passed"
          else
            gum style --foreground 196 "❌ Repository check failed"
            exit 1
          fi

          echo ""
          gum style --foreground 226 --bold "🔄 Step 2: Performing initial backup"
          echo ""
          if gum spin --spinner globe --title "Creating initial backup..." -- autorestic backup -a; then
            echo ""
            gum style --foreground 46 --bold "🎉 Backup system initialized successfully!"
            echo ""
            gum style --foreground 156 "You can now use:"
            echo "  • restic-backup    - Create new backups"
            echo "  • restic-restore   - Restore files"
            echo "  • restic-status    - Check backup status"
            echo "  • restic-list-files - Browse backup contents"
          else
            gum style --foreground 196 "❌ Initial backup failed"
            exit 1
          fi
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
        OnCalendar = "*-*-* 02:00:00";  # Daily at 2 AM (systemd format)
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}