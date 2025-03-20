{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ fish nixfmt ];

}