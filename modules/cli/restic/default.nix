{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  ...
}:
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
          default = "Sun *-*-* 23:00:00"; # 11 PM on Sundays (systemd format)
          description = "Schedule for periodic validation checks in systemd calendar format (default: 11 PM Sundays).";
        };

        type = lib.mkOption {
          type = lib.types.enum [
            "basic"
            "read-data-subset"
            "read-data"
          ];
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

      # keep-sorted start case=no numeric=yes
      unstable.autorestic
      unstable.backblaze-b2
      unstable.gum
      unstable.restic
      # keep-sorted end
    ];

    home-manager.users."${user-settings.user.username}" = {
      home = {
        file = {
          ".autorestic.yml".text = ''
          version: 2

          backends:
            b2-tower:
              type: b2
              path: 'ws-bups:tower'
              env:
                B2_ACCOUNT_ID: ${secrets.restic.b2_account_id}
                B2_ACCOUNT_KEY: ${secrets.restic.b2_account_key}
                RESTIC_PASSWORD: ${secrets.restic.restic_password}
            local-tower:
              type: local
              path: '/run/media/dustin/dk-data/Restic-backups/tower'
              env:
                RESTIC_PASSWORD: ${secrets.restic.restic_password}

          locations:
            ${cfg.folderName}-backup:
              from:
${lib.concatMapStringsSep "\n" (path: "                - ${path}") cfg.backupPaths}
              to:
                - b2-tower
                - local-tower
              cron: "${cfg.schedule}"
              forget: prune
              hooks:${lib.optionalString (cfg.localBackup.enable && cfg.localBackup.mountCheck.enable) ''
                prevalidate:
                  - test -d "${cfg.localBackup.path}" || (echo "❌ Local backup path not accessible at ${cfg.localBackup.path}" && exit 1)
                  - mountpoint -q "$(dirname "${cfg.localBackup.path}")" || (echo "❌ Parent directory $(dirname "${cfg.localBackup.path}") is not a mounted filesystem" && exit 1)
                  - test "$(df "${cfg.localBackup.path}" --output=avail | tail -1)" -gt 10485760 || (echo "❌ Insufficient disk space on ${cfg.localBackup.path} (less than 10GB available)" && exit 1)''}
                success:
                  - mkdir -p ~/.local/var/logs/restic
                  - 'echo "$(date -Iseconds): SUCCESS" >> ~/.local/var/logs/restic/backup.log'
                failure:
                  - mkdir -p ~/.local/var/logs/restic
                  - 'echo "$(date -Iseconds): FAILED" >> ~/.local/var/logs/restic/backup.log'
              options:
                backup:
                  exclude-file: /home/dustin/.autorestic-exclude
                forget:
${lib.concatStringsSep "
" (lib.mapAttrsToList (k: v: "                  ${k}: ${toString v}") cfg.retentionPolicy)}

          global:
            forget:
${lib.concatStringsSep "
" (lib.mapAttrsToList (k: v: "              ${k}: ${toString v}") cfg.retentionPolicy)}
        '';

          ".autorestic-exclude".text = lib.concatStringsSep "\n" cfg.excludePaths;
        };

        # Create convenience scripts
        packages = with pkgs; [
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
            ${lib.concatMapStringsSep "\n" (
              path: "            echo \"  • ${lib.last (lib.splitString "/" path)}\""
            ) cfg.backupPaths}

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
                      if [ "$BACKEND" = "local" ]${lib.optionalString cfg.localBackup.enable ''&& [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]''}; then
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

            if [ "$BACKEND" = "local" ]${lib.optionalString cfg.localBackup.enable ''&& [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]''}; then
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

            # Create logs directory
            mkdir -p ~/.local/var/logs/restic

            # Log detailed output for debugging
            LOG_FILE="$HOME/.local/var/logs/restic/status-$(date +%Y%m%d-%H%M%S).log"

            echo "📊 Restic Status - $(date)"
            echo ""

            # Backup Status
            if [ -f ~/.local/var/logs/restic/backup.log ]; then
              LAST_SUCCESS=$(grep "SUCCESS" ~/.local/var/logs/restic/backup.log | tail -1 | cut -d':' -f1)
              LAST_FAILURE=$(grep "FAILED" ~/.local/var/logs/restic/backup.log | tail -1 | cut -d':' -f1)

              if [ -n "$LAST_SUCCESS" ]; then
                echo "✅ Last backup: $(date -d "$LAST_SUCCESS" '+%m/%d %H:%M' 2>/dev/null || echo "$LAST_SUCCESS")"
              fi

              # Only show failure if it's more recent than success
              if [ -n "$LAST_FAILURE" ] && [ "$LAST_FAILURE" \> "$LAST_SUCCESS" ]; then
                echo "❌ Failed since: $(date -d "$LAST_FAILURE" '+%m/%d %H:%M' 2>/dev/null || echo "$LAST_FAILURE")"
              fi
            fi

            # Repository Health - only show if there are issues
            echo ""
            if autorestic check >/dev/null 2>>"$LOG_FILE"; then
              echo "✅ Repositories healthy"
            else
              echo "❌ Repository error detected - details in $LOG_FILE"
            fi

            # Quick snapshot count
            echo ""
            echo "📦 Snapshots:"
            CLOUD_COUNT=$(autorestic exec -b b2-${cfg.folderName} -- snapshots 2>>"$LOG_FILE" | grep -c "^[a-f0-9]" || echo "?")
            echo "  Cloud: $CLOUD_COUNT snapshots"

            ${lib.optionalString cfg.localBackup.enable ''
              if [ -d "${cfg.localBackup.path}/${cfg.folderName}" ]; then
                LOCAL_COUNT=$(autorestic exec -b local-${cfg.folderName} -- snapshots 2>>"$LOG_FILE" | grep -c "^[a-f0-9]" || echo "?")
                echo "  Local: $LOCAL_COUNT snapshots"
              else
                echo "  Local: not accessible"
              fi''}

            echo ""
            echo "📋 Logs:"
            echo "  Backup history: ~/.local/var/logs/restic/backup.log"
            ${lib.optionalString cfg.validation.enable ''echo "  Validation: ~/.local/var/logs/restic/validation.log"''}
            echo "  Latest status: $LOG_FILE"
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
    };

    # Systemd services and timers for automated backups and validation
    systemd.user = {
      services.autorestic-backup = {
        description = "Autorestic backup service";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScript "autorestic-backup" ''
            cd /home/${user-settings.user.username}
            ${pkgs.unstable.autorestic}/bin/autorestic backup -a
          ''}";
          User = user-settings.user.username;
          Group = "users";
        };
      };

      timers.autorestic-backup = {
        description = "Autorestic backup timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 02:00:00"; # TODO: Convert cfg.schedule from cron to systemd format
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
      };

      services.autorestic-validation = lib.mkIf cfg.validation.enable {
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
          Group = "users";
        };
      };

      timers.autorestic-validation = lib.mkIf cfg.validation.enable {
        description = "Autorestic validation timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.validation.schedule;
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      };
    };
  };
}
