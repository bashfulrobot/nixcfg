{ config, pkgs, lib, user-settings, ... }:
let cfg = config.suites.terminal;
in {

  options = {
    suites.terminal.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable terminal env..";
    };
  };

  config = lib.mkIf cfg.enable {
    cli = {
      alacritty.enable = true;
      starship.enable = true;
      bash.enable = true;
      fish.enable = true;
      zellij.enable = true;
      yazi.enable = false;
      foot.enable = false;
      blackbox.enable = true;
      ghostty.enable = false;
      ntf.enable = true;
      xkill.enable = true;
    };

    # A fuse filesystem that dynamically populates contents of /bin and /usr/bin/ so that it contains all executables from the PATH of the requesting process. This allows executing FHS based programs on a non-FHS system. For example, this is useful to execute shebangs on NixOS that assume hard coded locations like /bin or /usr/bin etc.
    services.envfs.enable = true;

    environment.systemPackages = with pkgs; [

      # --- Shell experience
      fzf # command-line fuzzy finder
      tealdeer # command-line help utility
      bottom # system monitoring tool
      jless # json/yaml parser
      fd # find alternative
      sd # sed alternative
      tree # directory structure viewer
      broot # Fuzzy finder
      eza # ls and exa alternative
      btop # top alternative
      pass # password manager

    ];

    programs = { pay-respects.enable = true; };

    home-manager.users."${user-settings.user.username}" = {

      # Daemon for managing long running shell commands
      services.pueue = {
        enable = true;
        settings = {
          client = {
            restart_in_place = false;
            read_local_logs = true;
            show_confirmation_questions = false;
            show_expanded_aliases = false;
            dark_mode = false;
            max_status_lines = null;
            status_time_format = "%H:%M:%S";
            status_datetime_format = ''
              %Y-%m-%d
              %H:%M:%S'';
          };
          daemon = {
            pause_group_on_failure = false;
            pause_all_on_failure = false;
            callback_log_lines = 10;
          };
          shared = { use_unix_socket = true; };
        };
      };

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
        tmux = { enable = true; };
        bat = { enable = true; };

        # navi = {
        #   enable = true;
        #   enableBashIntegration = true;
        #   enableFishIntegration = true;
        # };

        carapace = { enable = true; };
      };
    };
  };
}
