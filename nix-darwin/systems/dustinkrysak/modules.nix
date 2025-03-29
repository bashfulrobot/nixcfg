{ pkgs, ... }:
{

  imports = [
    # Universal Modules
    ../../../modules/cli/git
    ../../../modules/cli/opencommit
    ../../../modules/sys/ssh
    ../../../modules/sys/fonts
    ../../../modules/cli/starship
    ../../../modules/cli/fish
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
    fish.enable = true;
    starship.enable = true;
  };

  apps = {
    mimestream.enable = false;
  };
}
