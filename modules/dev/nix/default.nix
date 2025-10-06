{ user-settings, pkgs, config, lib, ... }:
let cfg = config.dev.nix;

in {
  options = {
    dev.nix.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable nix tooling.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      cachix # Binary cache client for pushing/pulling packages
      comma # Nix command wrapper
      keep-sorted # Keep code sorted
      # Nixd
      # https://github.com/nix-community/nixd/blob/main/docs/editor-setup.md
      # lsp for nix - mayb e for zed
      nix-index # Nix package indexer
      nix-prefetch-github # Get sha256 info for GitHub
      nixd # nix language server
      nixfmt-rfc-style # Nix code formatter
      nodePackages.node2nix # Node to Nix
      statix # nix linting
      unstable.nh # nix helper - rebuilds, etc
      # keep-sorted end
    ];
    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
