{ config, pkgs, lib, ... }:
# Fish shell system-wide installation and shell registration

{
    # Install fish system-wide
    environment.systemPackages = with pkgs; [
      fish
    ];

    # Add fish to /etc/shells
    environment.etc."shells".text = lib.concatStringsSep "\n" [
      "/bin/sh"
      "/bin/bash" 
      "/usr/bin/bash"
      "${pkgs.fish}/bin/fish"
    ];
}