{ config, pkgs, lib, user-settings, ... }:

{
  # Claude Code CLI configuration for home-manager in Ubuntu environment
  
  home.packages = with pkgs; [
    unstable.claude-code
  ];

  xdg.configFile."claude/CLAUDE.md".source = ../../../../modules/cli/claude-code/CLAUDE.md;

  programs.fish.shellAbbrs = {
    cc = {
      position = "command";
      setCursor = true;
      expansion = "claude -p \"%\"";
    };
  };
}