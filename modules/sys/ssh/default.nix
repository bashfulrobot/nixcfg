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
    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    home-manager.users."${user-settings.user.username}" = {

      programs.ssh = {
        enable = true;

        extraConfig = ''
        #   Host *
        #     AddKeysToAgent yes
          Host github.com
            HostName github.com
            IdentityFile ~/.ssh/id_ed25519
            User git
          Host bitbucket.org
              HostName bitbucket.org
              IdentityFile ~/.ssh/id_ed25519
              User git
          Host feral
              HostName aion.feralhosting.com
              User msgedme
          Host camino
            HostName 64.225.50.102
            User root
            AddKeysToAgent yes
          Host remi
            HostName 72.51.28.133
            User dustin
            AddKeysToAgent yes
          Host gigi
            HostName 100.96.21.6
            User dustin
            AddKeysToAgent yes
        #   Host tower-ts
        #       HostName 100.89.2.33
        #       User dustin
        #         AddKeysToAgent yes
        #   Host dt
        #       HostName 192.168.169.2
        #       User dustin
        #         AddKeysToAgent yes
          Host ub-ubuntubudgieorg
              HostName 157.245.237.69
              User dustin
                AddKeysToAgent yes
        #   Host ub-ubuntubudgieorg-nikola
        #       HostName 157.245.237.69
        #       User nikola
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
        #   Host srv
        #       HostName 192.168.168.1
        #       User dustin
        #       AddKeysToAgent yes
        # Used with TF/KVM
          Host 192.168.168.1
              HostName 192.168.168.1
              User dustin
              dKeysToAgent yes
              Port 22
              StrictHostKeyChecking no
              UserKnownHostsFile /dev/null
        #   Host srv-ts
        #         HostName 100.64.187.14
        #         User dustin
        #         AddKeysToAgent yes
        #   Host 100.64.187.14
        #         User dustin
        #         AddKeysToAgent yes
        #   Host nixdo
        #       HostName 192.168.168.10
        #       User dustin
        #         AddKeysToAgent yes
        #   Host rembot
        #     HostName 100.89.186.70
        #     User dustin
        #     AddKeysToAgent yes
        '';
      };
    };
  };
}
