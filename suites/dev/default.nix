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
      #   npm.enable = true;
      #   python.enable = true;
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
      oq.enable = true;
      yamllint.enable = true;
    };

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      awscli2
      ffuf
      gnumake
      jnv # json filtering with jq
      just # command runner
      markdown-oxide # Zed support
      nil # nix language server for Zed
      shadowenv # environment variable manager
      shfmt # shell script formatter
      unstable.doppler # secret management tool
      unstable.fx # Terminal JSON viewer
      unstable.helix # text editor
      unstable.httpie
      unstable.netlify-cli # Netlify CLI tool
      # unstable.jetbrains.goland # Go IDE
      unstable.pre-commit # pre-commit hooks
      unstable.yq-go # YAML processor (Go version)
      zed-editor # text editor
      # keep-sorted end
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
