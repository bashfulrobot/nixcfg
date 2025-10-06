{
  config,
  pkgs,
  lib,
  user-settings,
  ...
}:
let
  cfg = config.suites.terminal;
in
{

  options = {
    suites.terminal.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable terminal env..";
    };
  };

  config = lib.mkIf cfg.enable {
    cli = {
      alacritty.enable = false;
      starship.enable = true;
      bash.enable = true;
      fish.enable = true;
      tmux.enable = false;
      zellij.enable = true;
      yazi.enable = true;
      ranger.enable = false;
      blackbox.enable = false;
      ntf.enable = true;
      xkill.enable = true;
      kitty.enable = true;
      eza.enable = true;
    };

    # A fuse filesystem that dynamically populates contents of /bin and /usr/bin/ so that it contains all executables from the PATH of the requesting process. This allows executing FHS based programs on a non-FHS system. For example, this is useful to execute shebangs on NixOS that assume hard coded locations like /bin or /usr/bin etc.
    services.envfs.enable = true;

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      bottom # system monitoring tool
      broot # Fuzzy finder
      btop # top alternative
      eza # ls and exa alternative
      fd # find alternative
      fzf # command-line fuzzy finder
      jless # json/yaml parser
      pass # password manager
      sd # sed alternative
      tealdeer # command-line help utility
      tree # directory structure viewer
      wcurl # curl wget wrapper
      # keep-sorted end
    ];

    programs = {
      pay-respects.enable = true;
    };

    home-manager.users."${user-settings.user.username}" = {

      programs = {
        autojump = {
          enable = false;
          enableFishIntegration = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        zoxide = {
          enable = true;
          enableFishIntegration = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          options = [
            "--cmd cd" # just to stop me using cd
          ];
        };
        bat = {
          enable = true;
        };

        carapace = {
          enable = true;
        };
      };
    };
  };
}
