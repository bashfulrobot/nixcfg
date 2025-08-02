{ config, pkgs, lib, ... }:

let
  cfg = config.cli.direnv;
in {
  options.cli.direnv.system = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable direnv system-wide package installation";
  };

  config = lib.mkIf cfg.system {
    environment.systemPackages = with pkgs; [
      direnv
    ];
  };
}