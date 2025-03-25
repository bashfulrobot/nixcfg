{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ fd fish nixfmt raycast ];

}
