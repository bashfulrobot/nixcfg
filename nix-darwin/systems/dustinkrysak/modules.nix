{ pkgs, ... }:
{

  imports = [
    # Universal Modules
    ../../../modules/cli/git
    ../../../modules/cli/opencommit
    ../../../modules/sys/ssh
    ../../../modules/sys/fonts
    # Darwin Modules
    ../../modules/apps/mimestream
    ../../modules/cli/ghostty
  ];

  sys = {
    ssh.enable = true;
    fonts.enable = true;
  };

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
