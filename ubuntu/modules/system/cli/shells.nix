{ config, pkgs, lib, ... }:
# System shell registration for /etc/shells

{
    # Configure /etc/shells with standard Ubuntu shells plus Nix-managed shells
    environment.etc."shells".text = lib.concatStringsSep "\n" [
      # Standard Ubuntu system shells
      "/bin/sh"
      "/bin/bash"
      "/bin/rbash"
      "/bin/dash"
      "/usr/bin/sh"
      "/usr/bin/bash"
      "/usr/bin/rbash"
      "/usr/bin/dash"
      
      # Nix-managed shells
      "${pkgs.fish}/bin/fish"
    ];
}