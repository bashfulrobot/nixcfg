{ config, pkgs, lib, ... }:

{
  config = {
    # Claude Code system-wide installation
    environment.systemPackages = with pkgs; [
      unstable.claude-code
    ];
  };
}