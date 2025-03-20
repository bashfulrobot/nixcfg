{ pkgs, ... }:
{

  imports = [
    ../../modules/cli/ghostty
  ];

  cli.ghostty.enable = true;
}
