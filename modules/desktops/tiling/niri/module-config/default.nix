{ lib, config, ... }:
{
  imports = [
    ./portal.nix
    ./programs
    ./theme.nix
  ];
}
