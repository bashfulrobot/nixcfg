{ pkgs, ... }:
{

  imports = [
    ../../modules/cli/ghostty
    ../../../modules/cli/git
    ../../../modules/cli/opencommit
    ../../modules/apps/mimestream
  ];

  cli = {
    ghostty.enable = true;
    git.enable = true;
    opencommit.enable = true;
  };

  apps = {
    mimestream = {
      enable = true;
    };
  };
}
