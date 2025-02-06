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
        max-jobs = 4;
        cores = 4;
        http-connections = 50;
        warn-dirty = false;
        log-lines = 50;
        sandbox = "relaxed";
        # https://nixos.wiki/wiki/Storage_optimization
        auto-optimise-store = true;
        trusted-users = users;
        allowed-users = users;
        # Cachix - https://wiki.hyprland.org/nix/cachix/
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
        download-buffer-size = 1024 * 1024 * 1024;
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
