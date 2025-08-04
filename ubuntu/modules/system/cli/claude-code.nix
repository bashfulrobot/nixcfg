{ config, pkgs, lib, ... }:

{
  # Claude Code system-wide installation
  environment.systemPackages = with pkgs; [
    unstable.claude-code
  ];
}