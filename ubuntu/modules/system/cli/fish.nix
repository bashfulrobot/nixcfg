{ config, pkgs, lib, ... }:
# Fish shell system-wide installation and shell registration

{
    # Install fish system-wide
    environment.systemPackages = with pkgs; [
      fish
    ];

}