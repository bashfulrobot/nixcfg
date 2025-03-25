{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ fish nixfmt raycast lan-mouse ];

}
