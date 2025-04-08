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
    ../../../modules/cli/nixvim
    # Darwin Modules
    ../../modules/apps/mimestream
    ../../modules/apps/headlamp
    ../../modules/cli/ghostty
    ../../modules/cli/yabai
    ../../modules/cli/aerospace
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
    nixvim.enable = true;
    yabai.enable = false;
    aerospace.enable = true;
  };

  apps = {
    mimestream.enable = true;
    headlamp.enable = true;
  };
}
