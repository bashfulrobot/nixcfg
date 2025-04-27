{ user-settings, pkgs, config, lib, ... }:
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
    environment.systemPackages = with pkgs; [ srhd ];

    # launchd.user.agents.srhd = {
    #   path = [ config.environment.systemPath ];
    #   serviceConfig = {
    #     ProgramArguments = [ "${srhd}/bin/srhd start" ];
    #     KeepAlive = true;
    #     StandardOutPath = /tmp/srhd.out;
    #     StandardErrorPath = /tmp/srhd.err;
    #   };
    # };

    home-manager.users."${user-settings.user.username}" = {
      home.file.".config/srhd/srhd.toml".text = ''
        [[bindings]]
        key = "return"
        command = "open /Applications/Ghostty.app"
        mods = ["option"]
        [[bindings]]
        # key = "h"
        # command = "yabai -m window --focus west"
        # mods = ["option", "control"]
        key = "h"
        command = "echo 'hello from srhd'"
        mods = ["option", "control"]
        [[bindings]]
        key = "j"
        command = "yabai -m window --focus south"
        mods = ["option", "control"]
        [[bindings]]
        key = "k"
        command = "yabai -m window --focus north"
        mods = ["option", "control"]
        [[bindings]]
        key = "l"
        command = "yabai -m window --focus east"
        mods = ["option", "control"]
      '';
    };

  };
}
