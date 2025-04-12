{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ unstable.helix fd unstable.fish nixfmt nixfmt-rfc-style statix unstable.terraform unstable.pkgs.awscli2 ];

}
