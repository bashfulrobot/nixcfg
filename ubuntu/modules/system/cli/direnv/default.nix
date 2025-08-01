{ config, pkgs, lib, ... }:

let
  cfg = config.cli.direnv;
in {
  options.cli.direnv = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable direnv system-level support (envsubst package)";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-level packages for direnv support
    environment.systemPackages = with pkgs; [ 
      envsubst  # Required for envsubst functionality
      direnv    # Make direnv available system-wide
    ];
  };
}