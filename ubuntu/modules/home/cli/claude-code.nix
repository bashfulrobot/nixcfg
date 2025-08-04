{ config, pkgs, lib, ... }:

let
  user-settings = builtins.fromJSON (builtins.readFile ../../../settings/settings.json);
in {
  # Claude Code CLI configuration for home-manager in Ubuntu environment
  
  home.packages = with pkgs; [
    unstable.claude-code
  ];

  xdg.configFile."claude/CLAUDE.md".source = ../../../modules/cli/claude-code/CLAUDE.md;

  programs.fish.shellAbbrs = {
    cc = {
      position = "command";
      setCursor = true;
      expansion = "claude -p \"%\"";
    };
  };
}