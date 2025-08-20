{ user-settings, pkgs, config, lib, ... }:
let cfg = config.dev.go;

in {
  options = {
    dev.go.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable go tooling.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      go
    ];
    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
