{ user-settings, pkgs, secrets, config, lib, inputs, ... }:
let cfg = config.cli.blackbox;

in {
  options = {
    cli.blackbox.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Blackbox Terminal.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ blackbox-terminal ];

    home-manager.users."${user-settings.user.username}" = {
      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {
        "com/raggesilver/BlackBox" = {
          cursor-blink-mode = mkUint32 1;
          cursor-shape = uint32 0;
          custom-working-directory = "/home/dustin/dev";
          show-headerbar = true;
          font = "JetBrainsMonoNL Nerd Font Mono 14";
          scrollback-lines = mkUint32 50000;
          terminal-padding =
            mkTuple [ (mkUint32 15) (mkUint32 15) (mkUint32 15) (mkUint32 15) ];
          window-height = mkUint32 734;
          window-width = mkUint32 1215;
          working-directory-mode = mkUint32 2;
          theme-light = "Tomorrow";
        };

      };
    };
  };
}
