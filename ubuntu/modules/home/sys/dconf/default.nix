{ config, pkgs, lib, ... }:

let
  cfg = config.sys.dconf;
in
{
  options.sys.dconf = {
    enable = lib.mkEnableOption "Enable dconf editor and dconf2nix conversion tools";
  };

  config = lib.mkIf cfg.enable {
    # Install dconf tools via home-manager
    home.packages = with pkgs; [
      dconf-editor
      dconf2nix
    ];
  };
}