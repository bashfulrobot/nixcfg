{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.google-chrome;
in
{
  options = {
    apps.google-chrome = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Google Chrome browser.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      programs.chromium = {
        enable = true;
        package = pkgs.google-chrome;
        extensions = [
          # 1password
          "aeblfdkhhhdcdjpifhhbdiojplfjncoa"
          # ublock origin
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"
          # dark reader
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
        ];
      };

      home.sessionVariables.BROWSER = "google-chrome-stable";
    };
  };
}