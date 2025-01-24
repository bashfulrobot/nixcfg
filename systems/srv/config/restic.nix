{ user-settings, config, pkgs, secrets, ... }:
let
  restic-nfs-backup = ''
    #!/run/current-system/sw/bin/env bash

    set -euo pipefail

    RESTIC_HOST="$(hostname)"
    RESTIC_REPOSITORY="${secrets.restic.srv.restic_repository}"
    AWS_SECRET_ACCESS_KEY="${secrets.restic.srv.b2_account_id}"
    B2_ACCOUNT_KEY="${secrets.restic.srv.b2_account_key}"
    RESTIC_PASSWORD="${secrets.restic.srv.restic_password}"

    export RESTIC_HOST RESTIC_REPOSITORY B2_ACCOUNT_ID B2_ACCOUNT_KEY RESTIC_PASSWORD

    # Debugging output
    echo "RESTIC_REPOSITORY: $RESTIC_REPOSITORY"
    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
    echo "B2_ACCOUNT_KEY: $B2_ACCOUNT_KEY"
    echo "RESTIC_PASSWORD: $RESTIC_PASSWORD"

    PASSWORD_FILE=$(mktemp)
    echo "$RESTIC_PASSWORD" > "$PASSWORD_FILE"

    init_repo() {
      restic -r $RESTIC_REPOSITORY init
    }

    run_backup() {
      restic -r $RESTIC_REPOSITORY backup /srv/nfs
    }

    if [ "${"1:-"}" = "-init" ]; then
      init_repo
    else
      run_backup
    fi

    rm -f "$PASSWORD_FILE"
  '';
in {

  environment.systemPackages = with pkgs; [
    restic
    (writeScriptBin "restic-nfs-backup.sh" restic-nfs-backup)
  ];

  # systemd.services.autorestic = {
  #   description = "Autorestic Backup Service";
  #   serviceConfig = {
  #     ExecStart =
  #       "autorestic -c /home/${user-settings.user.username}/.autorestic.yaml --ci cron";
  #     User = "root";
  #   };
  # };

  # systemd.timers.autorestic = {
  #   description = "Autorestic Backup Timer";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "*:0/5";
  #     Persistent = true;
  #   };
  # };

  # home-manager.users."${user-settings.user.username}" = {
  # };
}
