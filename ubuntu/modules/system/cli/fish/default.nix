{ config, pkgs, lib, ... }:

let
  cfg = config.cli.fish;
in {
  options.cli.fish.system = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable fish shell system-wide installation and shell registration";
  };

  config = lib.mkIf cfg.system {
    # Install fish system-wide
    environment.systemPackages = with pkgs; [
      fish
    ];

    # Add fish to /etc/shells
    environment.etc."shells".text = lib.concatStringsSep "\n" [
      "/bin/sh"
      "/bin/bash" 
      "/usr/bin/bash"
      "${pkgs.fish}/bin/fish"
    ];
  };
}