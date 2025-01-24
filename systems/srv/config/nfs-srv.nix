{ config, pkgs, secrets, ... }: {

  environment.systemPackages = with pkgs; [ nfs-utils ];

  fileSystems."/exports/spitfire" = {
    device = "/srv/nfs/spitfire";
    options = [ "bind" ];
  };

  services = {
    nfs = {
      server = {
        enable = true;
        exports = ''
          /exports/spitfire 172.16.166.0/24(rw,sync,no_subtree_check,no_root_squash,all_squash,anonuid=1000,anongid=100)
        '';
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /exports/spitfire 0755 nobody nogroup -"
    "d /srv/nfs/spitfire 0755 1000 100 -"
    "d /srv/nfs/restores 0755 1000 100 -"
  ];
}
