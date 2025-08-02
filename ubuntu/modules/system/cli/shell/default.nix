{ config, pkgs, lib, ... }:

{
  config = {
    # Automatically add enabled shells to /etc/shells
    environment.etc."shells".text = lib.concatStringsSep "\n" (
      [
        "/bin/sh"
        "/bin/bash"
        "/usr/bin/bash"
      ] ++ lib.optionals config.cli.fish.enable [
        "${pkgs.fish}/bin/fish"
      ]
      # Future shells can be added here with similar conditionals
      # ++ lib.optionals config.cli.zsh.enable [
      #   "${pkgs.zsh}/bin/zsh"
      # ]
    );
  };
}