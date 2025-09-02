{ lib, config, ... }:
{
  imports = [
    ./env
    ./portals
    ./programs
    ./services
    ./theme
  ];
}
