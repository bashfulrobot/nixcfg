{ user-settings, secrets, pkgs, config, lib, ... }:

let
  cfg = config.cli.ntf;
  ntf = pkgs.callPackage ./build { };
  yamlFormat = pkgs.formats.yaml {};

  ntfConfig = {
    backends = [ "pushover" ];
    pushover = {
      user_key = secrets.pushover.user_key;
      priority = "emergency"; # options: emergency|high|normal|low|lowest
      retry = 30;
      expire = 3600;
    };
  };

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

      home.file.".ntf.yml".source = yamlFormat.generate "ntf.yml" ntfConfig;

    };
  };
}
