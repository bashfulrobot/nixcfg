{ user-settings, lib, pkgs, secrets, config, isWorkstation, ... }:
let
  cfg = config.cli.fish;
  fd-flags = lib.concatStringsSep " " [ "--hidden" "--exclude '.git'" ];
  isDarwin = pkgs.stdenv.isDarwin;

  # Import separate configuration files
  fishFunctions = import ./functions.nix { inherit lib isDarwin pkgs user-settings; };
  fishAbbrs = import ./abbrs.nix { inherit lib isDarwin; };
  fishAliases = import ./aliases.nix { inherit lib isDarwin pkgs user-settings; };

in {

  options = {
    cli.fish.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the fish shell.";
    };
  };

  config = lib.mkIf cfg.enable {
    # You can enable the fish shell and manage fish configuration and plugins with Home Manager, but to enable vendor fish completions provided by Nixpkgs you will also want to enable the fish shell in /etc/nixos/configuration.nix:
    programs.fish.enable = true;

    environment.shells = lib.mkIf isDarwin [ pkgs.fish ];

    home-manager.users."${user-settings.user.username}" = {
      programs.fish = {
        enable = true;
        shellInit = if isWorkstation then ''
          # Shell Init
          direnv hook fish | source
          ${lib.optionalString (!isDarwin)
          "source ${user-settings.user.home}/.config/op/plugins.sh"}
        '' else
          "";
        interactiveShellInit = if isWorkstation then ''
          set fish_greeting # Disable greeting
          ${lib.optionalString (!isDarwin)
          "source ${user-settings.user.home}/.config/op/plugins.sh"}
        '' else ''
          set fish_greeting # Disable greeting
        '';

        # Use imported functions, abbrs, and aliases
        functions = fishFunctions;
        shellAbbrs = fishAbbrs;
        shellAliases = fishAliases;
      };

      programs = {
        fzf = {
          enable = true;
          enableFishIntegration = true;
          defaultCommand = "fd --type f ${fd-flags}";
          fileWidgetCommand = "fd --type f ${fd-flags}";
          changeDirWidgetCommand = "fd --type d ${fd-flags}";
        };
        atuin = {
          enable = true;
          enableFishIntegration = true;
          flags = [ "--disable-up-arrow" ];
          settings = {
            auto_sync = true;
            sync_frequency = "5m";
            sync_address = "https://api.atuin.sh";
            search_mode = "fuzzy";
            filter_mode_shell_up_key_binding = "directory";
            style = "compact";

          };
        };
        yazi.enableFishIntegration = true;
        nix-index.enableFishIntegration = true;
        eza.enableFishIntegration = true;
        autojump.enableFishIntegration = false;
      };

      home.packages = with pkgs; [
        fishPlugins.tide
        fishPlugins.grc
        grc
        fishPlugins.github-copilot-cli-fish
        fishPlugins.fzf-fish
        fishPlugins.colored-man-pages
        fishPlugins.bass
        fishPlugins.autopair
        # fishPlugins.async-prompt
        fishPlugins.done
        fishPlugins.forgit
        fishPlugins.sponge
        gum
      ];
    };
  };
}
