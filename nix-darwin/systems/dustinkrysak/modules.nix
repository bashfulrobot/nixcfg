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
    ../../../modules/cli/helix
    # Darwin Modules
    ../../modules/apps/mimestream
    ../../modules/apps/headlamp
    ../../modules/cli/ghostty
    ../../modules/cli/aerospace
    ../../modules/cli/yabai
    ../../modules/cli/srhd
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
    nixvim.enable = false;
    aerospace.enable = false;
    yabai.enable = true;
    srhd.enable = true;
    helix.enable = true;
  };

  apps = {
    mimestream.enable = true;
    headlamp.enable = true;
  };
}
