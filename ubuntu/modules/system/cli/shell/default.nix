{ config, pkgs, lib, ... }:

{
  config = {
    # Always add common shells and fish to /etc/shells
    environment.etc."shells".text = lib.concatStringsSep "\n" [
      "/bin/sh"
      "/bin/bash" 
      "/usr/bin/bash"
      "${pkgs.fish}/bin/fish"
      # Future shells can be added here
    ];
  };
}