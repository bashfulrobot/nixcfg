{ config, pkgs, lib, ... }:
# Fish shell system-wide installation and shell registration

{
  config = {
    # Install fish system-wide
    environment.systemPackages = with pkgs; [
      fish
    ];
  };
}