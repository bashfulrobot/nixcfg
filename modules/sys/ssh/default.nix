{ user-settings, config, lib, pkgs, ... }:
let cfg = config.sys.ssh;

in {

  options = {
    sys.ssh.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ssh.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;

    home-manager.users."${user-settings.user.username}" = {

      programs.ssh = {
        enable = true;

        extraConfig = ''

          ### Home Config
          Host remi
            HostName 72.51.28.133
            User dustin
            AddKeysToAgent yes
          Host gigi
            HostName 100.96.21.6
            User dustin
            AddKeysToAgent yes

          ### Camino Config
          Host camino
            HostName 64.225.50.102
            User root
            AddKeysToAgent yes

          # Ubuntu Budgie Config
          Host ub-ubuntubudgieorg
            HostName 157.245.237.69
            User dustin
            AddKeysToAgent yes
          Host ub-ubuntubudgieorg-webpub
            HostName 157.245.237.69
            User webpub
          Host ub-docker-root
            HostName 134.209.129.108
            User dustin
            AddKeysToAgent yes
          Host ub-docker-admin
            HostName 134.209.129.108
            User docker-admin
            AddKeysToAgent yes

          ### Feral Config
          Host feral
            HostName prometheus.feralhosting.com
            User msgedme

          ### Git Config
          Host github.com
            HostName github.com
            IdentityFile ~/.ssh/id_ed25519
            User git
          Host bitbucket.org
            HostName bitbucket.org
            IdentityFile ~/.ssh/id_ed25519
            User git
          Host git.srvrs.co
            HostName git.srvrs.co
            IdentityFile ~/.ssh/id_ed25519
            User git

          ### TF/KVM Config
          Host 192.168.168.1
            HostName 192.168.168.1
            User dustin
            AddKeysToAgent yes
            Port 22
            StrictHostKeyChecking no
            UserKnownHostsFile /dev/null

          # Global Config
          Host *
            IgnoreUnknown UseKeychain
            AddKeysToAgent yes
            UseKeychain yes
            IdentitiesOnly yes
        '';
      };
    };
  };
}
