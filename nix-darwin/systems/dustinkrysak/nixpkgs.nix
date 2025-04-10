{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ fd fish nixfmt nixfmt-rfc-style statix unstable.terraform unstable.pkgs.awscli2 ];

}
