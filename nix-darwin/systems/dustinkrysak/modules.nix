{ pkgs, ... }:
{

  imports = [
    ../../modules/cli/ghostty
    ../../../modules/cli/git
  ];

  cli = {
    ghostty.enable = true;
    git.enable = true;
  };
}
