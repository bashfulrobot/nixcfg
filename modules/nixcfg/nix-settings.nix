{ pkgs, lib, config, inputs, ... }:
let cfg = config.nixcfg.nix-settings;
in {

  options = {
    nixcfg.nix-settings.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the core archetype.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Means the program will be run via nix-shell. (The grabage collector may remove it on the next GC run.)
    # Used to run a program in a nix-shell environment when it is not installed just by running the program. ALternative to "comma".
    # Also enable command not found to use
    environment.variables = {
      NIX_AUTO_RUN = "1";
      NIX_AUTO_RUN_INTERACTIVE = "1";
    };

    # Enable Nix/Flakes
    nix = let users = [ "root" "dustin" ];

    in {
      # Disable channels since using flakes.
      channel.enable = false;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        max-jobs = "auto";  # Use all available cores for parallel building
        cores = 0;          # Use all available cores per job
        http-connections = 50;
        warn-dirty = false;
        log-lines = 50;
        sandbox = "relaxed";
        # https://nixos.wiki/wiki/Storage_optimization
        auto-optimise-store = true;
        trusted-users = users;
        allowed-users = users;
        # System-level cache configuration (prevents flake trust prompts)
        substituters = [
          "https://cache.nixos.org/"
          "https://hyprland.cachix.org"
          "https://nix-community.cachix.org"
          "https://numtide.cachix.org"
          "https://devenv.cachix.org"
          "https://pre-commit-hooks.cachix.org"
        ];
        trusted-substituters = [
          "https://cache.nixos.org/"
          "https://hyprland.cachix.org"
          "https://nix-community.cachix.org"
          "https://numtide.cachix.org"
          "https://devenv.cachix.org"
          "https://pre-commit-hooks.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBr7Vo="
        ];
        # Binary caches configured both here and in flake for redundancy
        download-buffer-size = 1024 * 1024 * 1024;
        # Performance optimizations for faster rebuilds
        keep-outputs = true;
        keep-derivations = true;
        builders-use-substitutes = true;
        # Additional performance settings
        eval-cache = true;
        narinfo-cache-positive-ttl = 3600;
        narinfo-cache-negative-ttl = 60;
        fsync-metadata = false;  # Faster on SSDs
        connect-timeout = 10;    # Faster timeout handling
        max-substitution-jobs = 32;  # Increased parallel downloads
        keep-build-log = false;  # Reduce storage overhead
        compress-build-log = true;

        # Store optimization settings
        keep-going = true;           # Continue building other derivations on failure
        fallback = true;             # Fall back to building if substitution fails
        min-free = 1073741824;       # Keep 1GB free (triggers GC)
        max-free = 3221225472;       # Stop GC at 3GB free
      };
      # Automatic Garbage Collection
      # Disbaled in favour of NH garbage cleaning.
      # leaving code in case I move away form NH.
      # gc = {
      #   automatic = true;
      #   dates = "weekly";
      #   options = "--delete-older-than 5d";
      # };
    };

    programs = {
      command-not-found.enable = true;
      nix-ld = {
        enable = true;
        libraries = with pkgs;
          [
            # Add any missing dynamic libraries here for unpackages programs
            # here, and not in the environment.systemPackages.
          ];
      };
      nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 4d --keep 3";
        flake = "/home/dustin/dev/nix/nixcfg";
      };
    };

    # TODO: fix this, it's not working
    # A set of shell script fragments that are executed when a NixOS system configuration is activated. Examples are updating /etc, creating accounts, and so on. Since these are executed every time you boot the system or run nixos-rebuild, it’s important that they are idempotent and fast.
    # system.activationScripts.diff = {
    #   # supportsDryActivaton = true;
    #   # TODO: where is $systemConfig defined?
    #   text = ''
    #     ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nvd}/bin diff /run/current-system "$systemConfig"
    #   '';
    # };

    # Allow unfree packages
    nixpkgs.config = { allowUnfree = true; };
  };
}
