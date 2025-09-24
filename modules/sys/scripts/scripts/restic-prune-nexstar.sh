#!/run/current-system/sw/bin/env bash

restic --password-command 'pass automation/restic-nexstar' -r /media/dustin/EXTERNAL/backups/desktop/ forget --prune --keep-daily 14 --keep-weekly 5 --keep-monthly 12 --keep-yearly 75 && RESULT="$(restic --password-command 'pass automation/restic-nexstar' -r /media/dustin/EXTERNAL/backups/desktop/ check)"

# telegram-send "$RESULT"

exit 0