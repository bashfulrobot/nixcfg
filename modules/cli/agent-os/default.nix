{ user-settings, lib, pkgs, config, ... }:
let
  cfg = config.cli.agent-os;
in
{
  options = {
    cli.agent-os.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Agent-OS project initialization CLI tool.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      programs.fish.shellAliases = {
        aos-project-init = "${user-settings.user.home}/.agent-os/setup/project.sh";
      };
    };
  };
}