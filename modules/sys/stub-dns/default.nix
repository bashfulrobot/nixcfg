{
  user-settings,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sys.disable-stub-dns;

in
{

  options = {
    sys.disable-stub-dns.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable Stub DNS Server.";
    };
  };

  config = lib.mkIf cfg.enable {

    services.resolved = {
      # Disable local DNS stub listener on 127.0.0.53
      extraConfig = ''
        DNSStubListener=no
      '';
    };

    #home-manager.users."${user-settings.user.username}" = {

    #};
  };
}
