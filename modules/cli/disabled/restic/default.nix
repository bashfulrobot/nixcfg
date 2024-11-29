{ user-settings, pkgs, secrets, config, lib, ... }:
let
  cfg = config.cli.restic;

  resticPort = 9999;

in {
  options = {
    cli.restic.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Restic tool, and backup jobs.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      restic # backup program
      autorestic # restic automation tool
    ];

    services.restic.server = {
      enable = true;
      prometheus = true;
      # extraFlags = [ "--no-auth" ]; # This is fine, as we are only reachable through VPN
      listenAddress = "127.0.0.1:${toString resticPort}";
    };

    home-manager.users."${user-settings.user.username}" = {

      home.file.".config/spotify-player/themes.toml".text = "\n";
    };
  };
}
