{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  ...
}:
let
  cfg = config.test.syshome;

in
{
  options = {
    test.syshome.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Test system and home manager merged.";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-manager: Create /etc/test file
    environment.etc."test".text = "system manager";

    # Home-manager: Create ~/.config/test/test file
    home-manager.users."${user-settings.user.username}" = {
      home.file.".config/test/test".text = "home manager";
    };
  };
}
