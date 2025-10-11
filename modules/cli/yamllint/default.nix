{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.cli.yamllint;
in
{
  options = {
    cli.yamllint = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable yamllint YAML linter and yamale schema validator.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yamllint
      yamale
    ];
  };
}