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
          /exports/spitfire 172.16.166.10(rw,sync,no_subtree_check) \
                            172.16.166.11(rw,sync,no_subtree_check) \
                            172.16.166.12(rw,sync,no_subtree_check) \
                            172.16.166.20(rw,sync,no_subtree_check) \
                            172.16.166.21(rw,sync,no_subtree_check)
        '';
      };
    };
  };
}
