{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./config/autoimport.nix ../../modules/autoimport.nix ];

}
