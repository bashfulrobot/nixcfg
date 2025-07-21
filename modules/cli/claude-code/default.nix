{ user-settings, lib, pkgs, config, ... }:
let 
  cfg = config.cli.claude-code;
in {
  options = {
    cli.claude-code.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable claude-code CLI tool.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.claude-code
    ];

    home-manager.users."${user-settings.user.username}" = {
      xdg.configFile."claude/CLAUDE.md".source = ./CLAUDE.md;

      programs.fish.shellAbbrs = {
        cc = {
          position = "command";
          setCursor = true;
          expansion = "claude -p \"%\"";
        };
      };
    };
  };
}