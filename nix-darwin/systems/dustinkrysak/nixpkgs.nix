{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ helix fd fish nixfmt nixfmt-rfc-style statix unstable.terraform unstable.pkgs.awscli2 ];

}
