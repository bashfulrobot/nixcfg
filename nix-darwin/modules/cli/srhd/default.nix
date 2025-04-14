{user-settings, pkgs, config, lib, ... }:
let
  srhd = pkgs.callPackage ./build.nix { };
  cfg = config.cli.srhd;
in {
  options = {
    cli.srhd.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable srhd shortcut daemon.";
    };
  };

  config = lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        srhd
      ];

    launchd.user.agents.srhd = {
      path = [ config.environment.systemPath ];
      serviceConfig = {
        ProgramArguments = [ "${srhd}/bin/srhd start" ];
        KeepAlive = true;
        StandardOutPath = /tmp/srhd.out;
        StandardErrorPath = /tmp/srhd.err;
      };
    };

        home-manager.users."${user-settings.user.username}" = {
          home.file.".config/srhd/srhd.toml".text = ''
          [[bindings]]
          key = "return"
          command = "open /Applications/Ghostty.app"
          mods = ["option"]
          [[bindings]]
          key = "f"
          command = "yabai -m window --toggle zoom-fullscreen"
          mods = ["control", "option", "command"]œ

          '';
    };

  };
}
