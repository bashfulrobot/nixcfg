{ config, pkgs, lib, ... }:

let
  cfg = config.cli.direnv;
in {
  options.cli.direnv = {
    enable = lib.mkEnableOption "Enable direnv system packages";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      direnv
    ];
  };
}