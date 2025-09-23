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

      validation = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable periodic repository validation.";
        };

        schedule = lib.mkOption {
          type = lib.types.str;
          default = "Sun *-*-* 23:00:00";  # 11 PM on Sundays (systemd format)
          description = "Schedule for periodic validation checks in systemd calendar format (default: 11 PM Sundays).";
        };

        type = lib.mkOption {
          type = lib.types.enum [ "basic" "read-data-subset" "read-data" ];
          default = "read-data-subset";
          description = "Type of validation: basic (fast), read-data-subset (moderate), read-data (thorough).";
        };

        dataSubsetPercent = lib.mkOption {
          type = lib.types.str;
          default = "10%";
          description = "Percentage of data to verify when using read-data-subset validation.";
        };
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

        mountCheck = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable prevalidation check to ensure mount point is accessible before backup.";
          };
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
    hooks:${lib.optionalString (cfg.localBackup.enable && cfg.localBackup.mountCheck.enable) ''
      prevalidate:
        - test -d "${cfg.localBackup.path}" || (echo "Local backup path not accessible at ${cfg.localBackup.path}" && exit 1)''}
      success:
        - mkdir -p ~/.local/var/logs/restic
        - echo "$(date -Iseconds): SUCCESS" >> ~/.local/var/logs/restic/backup.log
      failure:
        - mkdir -p ~/.local/var/logs/restic
        - echo "$(date -Iseconds): FAILED" >> ~/.local/var/logs/restic/backup.log
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

            # Create logs directory if it doesn't exist
            mkdir -p ~/.local/var/logs/restic

            if gum spin --spinner globe --title "Backing up files..." -- autorestic backup -a; then
              echo ""
              gum style --foreground 46 --bold "✅ Backup completed successfully!"
              echo "$(date -Iseconds): SUCCESS (manual)" >> ~/.local/var/logs/restic/backup.log
            else
              echo ""
              gum style --foreground 196 --bold "❌ Backup failed!"
              echo "$(date -Iseconds): FAILED (manual)" >> ~/.local/var/logs/restic/backup.log
              exit 1
            fi
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
          gum style --foreground 156 --bold "🕒 Automated Backup Status"
          echo ""

          # Show last backup attempt from systemd logs
          LAST_SYSTEMD_LOG=$(journalctl --user -u autorestic-backup.service --since "30 days ago" --no-pager -n 1 --output cat 2>/dev/null | tail -1)

          if [ -n "$LAST_SYSTEMD_LOG" ]; then
            LAST_ATTEMPT=$(journalctl --user -u autorestic-backup.service --since "30 days ago" --no-pager -n 1 --output short-iso 2>/dev/null | head -1 | cut -d' ' -f1)
            if echo "$LAST_SYSTEMD_LOG" | grep -q "Failed\|failed\|error\|Error"; then
              gum style --foreground 196 "❌ Last attempt: $LAST_ATTEMPT (FAILED)"
            else
              gum style --foreground 46 "✅ Last attempt: $LAST_ATTEMPT"
            fi
          else
            gum style --foreground 208 "⚠️  No recent backup attempts found in systemd logs"
          fi

          # Show backup history from our custom log
          if [ -f ~/.local/var/logs/restic/backup.log ]; then
            LAST_SUCCESS=$(grep "SUCCESS" ~/.local/var/logs/restic/backup.log | tail -1 | cut -d':' -f1)
            LAST_FAILURE=$(grep "FAILED" ~/.local/var/logs/restic/backup.log | tail -1 | cut -d':' -f1)

            if [ -n "$LAST_SUCCESS" ]; then
              gum style --foreground 46 "✅ Last successful backup: $(date -d "$LAST_SUCCESS" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo "$LAST_SUCCESS")"
            else
              gum style --foreground 208 "⚠️  No successful backups recorded yet"
            fi

            if [ -n "$LAST_FAILURE" ]; then
              gum style --foreground 196 "❌ Last failed backup: $(date -d "$LAST_FAILURE" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo "$LAST_FAILURE")"
            fi

            # Show recent backup history (last 10 entries)
            RECENT_COUNT=$(wc -l < ~/.local/var/logs/restic/backup.log 2>/dev/null || echo "0")
            if [ "$RECENT_COUNT" -gt 0 ]; then
              echo ""
              gum style --foreground 156 "📋 Recent backup history (last 10):"
              tail -10 ~/.local/var/logs/restic/backup.log | while read line; do
                if echo "$line" | grep -q "SUCCESS"; then
                  echo "  ✅ $line"
                else
                  echo "  ❌ $line"
                fi
              done | gum format
            fi
          else
            gum style --foreground 208 "⚠️  No backup log found at ~/.local/var/logs/restic/backup.log"
          fi

          ${lib.optionalString cfg.validation.enable ''
          echo ""
          gum style --foreground 156 --bold "🔍 Repository Validation Status"
          echo ""

          # Show validation history from validation log
          if [ -f ~/.local/var/logs/restic/validation.log ]; then
            # Get last successful validation for each backend
            LAST_CLOUD_SUCCESS=$(grep "VALIDATION_SUCCESS cloud" ~/.local/var/logs/restic/validation.log | tail -1 | cut -d':' -f1-3)
            LAST_CLOUD_FAILURE=$(grep "VALIDATION_FAILED cloud" ~/.local/var/logs/restic/validation.log | tail -1 | cut -d':' -f1-3)

            if [ -n "$LAST_CLOUD_SUCCESS" ]; then
              gum style --foreground 46 "✅ Cloud validation (last success): $(date -d "$LAST_CLOUD_SUCCESS" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo "$LAST_CLOUD_SUCCESS")"
            else
              gum style --foreground 208 "⚠️  No successful cloud validations recorded yet"
            fi

            if [ -n "$LAST_CLOUD_FAILURE" ]; then
              gum style --foreground 196 "❌ Cloud validation (last failure): $(date -d "$LAST_CLOUD_FAILURE" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo "$LAST_CLOUD_FAILURE")"
            fi

            ${lib.optionalString cfg.localBackup.enable ''
            LAST_LOCAL_SUCCESS=$(grep "VALIDATION_SUCCESS local" ~/.local/var/logs/restic/validation.log | tail -1 | cut -d':' -f1-3)
            LAST_LOCAL_FAILURE=$(grep "VALIDATION_FAILED local" ~/.local/var/logs/restic/validation.log | tail -1 | cut -d':' -f1-3)

            if [ -n "$LAST_LOCAL_SUCCESS" ]; then
              gum style --foreground 46 "✅ Local validation (last success): $(date -d "$LAST_LOCAL_SUCCESS" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo "$LAST_LOCAL_SUCCESS")"
            else
              gum style --foreground 208 "⚠️  No successful local validations recorded yet"
            fi

            if [ -n "$LAST_LOCAL_FAILURE" ]; then
              gum style --foreground 196 "❌ Local validation (last failure): $(date -d "$LAST_LOCAL_FAILURE" '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || echo "$LAST_LOCAL_FAILURE")"
            fi''}

            # Show recent validation history (last 5 entries)
            RECENT_VALIDATION_COUNT=$(wc -l < ~/.local/var/logs/restic/validation.log 2>/dev/null || echo "0")
            if [ "$RECENT_VALIDATION_COUNT" -gt 0 ]; then
              echo ""
              gum style --foreground 156 "📋 Recent validation history (last 5):"
              tail -5 ~/.local/var/logs/restic/validation.log | while read line; do
                if echo "$line" | grep -q "VALIDATION_SUCCESS"; then
                  echo "  ✅ $line"
                elif echo "$line" | grep -q "VALIDATION_FAILED"; then
                  echo "  ❌ $line"
                elif echo "$line" | grep -q "VALIDATION_SKIPPED"; then
                  echo "  ⏭️  $line"
                else
                  echo "  📝 $line"
                fi
              done | gum format
            fi

            # Show validation configuration
            echo ""
            gum style --foreground 156 "🔧 Validation settings: ${cfg.validation.type} validation, scheduled ${cfg.validation.schedule}"
          else
            gum style --foreground 208 "⚠️  No validation log found at ~/.local/var/logs/restic/validation.log"
            gum style --foreground 156 "🔧 Validation settings: ${cfg.validation.type} validation, scheduled ${cfg.validation.schedule}"
          fi''}

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

    # Systemd service and timer for periodic validation
    systemd.user.services.autorestic-validation = lib.mkIf cfg.validation.enable {
      description = "Autorestic repository validation service";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "autorestic-validation" ''
          cd /home/${user-settings.user.username}

          # Create logs directory if it doesn't exist
          mkdir -p ~/.local/var/logs/restic

          # Determine validation flags based on configuration
          VALIDATION_FLAGS=""
          case "${cfg.validation.type}" in
            "basic")
              VALIDATION_FLAGS=""
              ;;
            "read-data-subset")
              VALIDATION_FLAGS="--read-data-subset ${cfg.validation.dataSubsetPercent}"
              ;;
            "read-data")
              VALIDATION_FLAGS="--read-data"
              ;;
          esac

          # Run validation on all backends and capture results
          OVERALL_SUCCESS=true

          # Validate cloud backend
          echo "$(date -Iseconds): VALIDATION_START cloud $VALIDATION_FLAGS" >> ~/.local/var/logs/restic/validation.log
          if ${pkgs.unstable.autorestic}/bin/autorestic exec -b b2-${cfg.folderName} -- check $VALIDATION_FLAGS; then
            echo "$(date -Iseconds): VALIDATION_SUCCESS cloud" >> ~/.local/var/logs/restic/validation.log
          else
            echo "$(date -Iseconds): VALIDATION_FAILED cloud" >> ~/.local/var/logs/restic/validation.log
            OVERALL_SUCCESS=false
          fi

          ${lib.optionalString cfg.localBackup.enable ''
          # Validate local backend if enabled and accessible
          if [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]; then
            echo "$(date -Iseconds): VALIDATION_START local $VALIDATION_FLAGS" >> ~/.local/var/logs/restic/validation.log
            if ${pkgs.unstable.autorestic}/bin/autorestic exec -b local-${cfg.folderName} -- check $VALIDATION_FLAGS; then
              echo "$(date -Iseconds): VALIDATION_SUCCESS local" >> ~/.local/var/logs/restic/validation.log
            else
              echo "$(date -Iseconds): VALIDATION_FAILED local" >> ~/.local/var/logs/restic/validation.log
              OVERALL_SUCCESS=false
            fi
          else
            echo "$(date -Iseconds): VALIDATION_SKIPPED local (directory not accessible)" >> ~/.local/var/logs/restic/validation.log
          fi''}

          # Exit with appropriate code
          if [ "$OVERALL_SUCCESS" = true ]; then
            exit 0
          else
            exit 1
          fi
        ''}";
        User = user-settings.user.username;
      };
    };

    systemd.user.timers.autorestic-validation = lib.mkIf cfg.validation.enable {
      description = "Autorestic validation timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.validation.schedule;
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };
  };
}