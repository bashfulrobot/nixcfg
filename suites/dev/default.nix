{ config, pkgs, lib, user-settings, inputs, ... }:
let cfg = config.suites.dev;
in {

  options = {
    suites.dev.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable dev tooling..";
    };
  };

  config = lib.mkIf cfg.enable {
    # dev = {
    #   go.enable = true;
    #   npm.enable = true;
    #   python.enable = true;
    #   nix.enable = true;
    # };

    apps = {
      vscode.enable = true;
      # nixpkgs-search.enable = true;
      # nixos-discourse.enable = true;
      # nixos-wiki.enable = true;
      # hm-search.enable = true;
      # github-code-search.enable = true;
      # github.enable = true;
    };

    cli = {
      direnv.enable = true;
      git.enable = true;
      # nixvim.enable = true;
    };

environment.systemPackages = with pkgs; [

      just # command runner
      # doppler # secret management tool
      shadowenv # environment variable manager
      shfmt # shell script formatter
      jnv # json filtering with jq
      # unstable.zed-editor # text editor
      # unstable.jetbrains.goland # Go IDE
    ];
    home-manager.users."${user-settings.user.username}" = {
      programs = { jq = { enable = true; }; };
    };
  };
}