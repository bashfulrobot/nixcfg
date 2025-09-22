{
  config,
  lib,
  user-settings,
  ...
}:
let
  cfg = config.cli.tmux;
in
{
  options = {
    cli.tmux.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable tmux terminal multiplexer.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      programs.tmux = {
        enable = true;
        shell = "${config.programs.fish.package}/bin/fish";
        historyLimit = 50000;
        clock24 = true;
        mouse = true;
        terminal = "tmux-256color";
        focusEvents = true;
      };

      programs.fzf.tmux = {
        enableShellIntegration = true;
      };
    };
  };
}