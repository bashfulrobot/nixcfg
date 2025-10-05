{ config, lib, ... }:
let
  cfg = config.nixcfg.binary-caches;
in {
  options = {
    nixcfg.binary-caches.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable standard binary caches for faster builds";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      # Standard substituters in priority order
      substituters = [
        "https://cache.nixos.org/"                    # Official NixOS cache (highest priority)
        "https://nix-community.cachix.org"            # Community packages
        "https://numtide.cachix.org"                  # Popular development tools
        "https://devenv.cachix.org"                   # Development environments
        "https://pre-commit-hooks.cachix.org"         # Pre-commit hooks
      ];

      # Corresponding public keys for verification
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy2Aw+uQ9yNNhCNrOzwy3A+k0EVKA="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBr7Vo="
      ];

      # netrc-file = "/etc/nix/netrc"; # Support authenticated caches (if needed)
    };
  };
}