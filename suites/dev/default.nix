{
  config,
  pkgs,
  lib,
  user-settings,
  ...
}:
let
  cfg = config.suites.dev;
in
{

  options = {
    suites.dev.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable dev tooling..";
    };
  };

  config = lib.mkIf cfg.enable {
    dev = {
        go.enable = true;
      nix.enable = true;
    };

    apps = {
      vscode.enable = true;
      nixpkgs-search.enable = true;
      nixos-discourse.enable = true;
      nixos-wiki.enable = true;
      hm-search.enable = true;
      github-code-search.enable = true;
      github.enable = true;
    };

    cli = {
      direnv.enable = true;
      git.enable = true;
      helix.enable = true;
      claude-code.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gnumake
      awscli2
      ffuf
      just # command runner
      doppler # secret management tool
      shadowenv # environment variable manager
      shfmt # shell script formatter
      jnv # json filtering with jq
      zed-editor # text editor
      markdown-oxide # Zed support
      nil # nix language server for Zed
      # jetbrains.goland # Go IDE
      pre-commit # pre-commit hooks
      helix # text editor
      gemini-cli # Gemini CLI client
      nix-fast-build # parallel nix evaluation
    ];

    # programs = { jqp = { enable = true; }; };

    home-manager.users."${user-settings.user.username}" = {
      programs = {
        jq = {
          enable = true;
        };
      };
    };
  };
}
