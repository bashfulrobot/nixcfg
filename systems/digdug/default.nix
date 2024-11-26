{ config, pkgs, lib, inputs, ... }:

{
  imports = [ 
    ./config/autoimport.nix
    ../../modules/autoimport.nix 
    ../../archetype/autoimport.nix
    # ../../suites/autoimport.nix ];

}
