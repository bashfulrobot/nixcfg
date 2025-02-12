{ user-settings, secrets, pkgs, config, lib, ... }:

let
  cfg = config.cli.ntf;
  ntf = pkgs.callPackage ./build { };

in {
  options = {
    cli.ntf.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ntf for notifications.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      home.packages = with pkgs; [ ntf ];

      home.file.".ntf.yml".text = ''
        backends:
          - pushover
        pushover:
          user_key: '${secrets.pushover.user_key}'
          priority: 'emergency' #option (emergency|high|normal|low|lowest)
          retry: 30 #option
          expire: 3600 #option
      '';

    };
  };
}
