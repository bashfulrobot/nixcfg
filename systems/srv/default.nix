# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware
    ./networking
    ./config
    # ../../modules/autoimport.nix # autoimport modules
    # TODO: make an importable file of common server modules

    # Common modules
    ../common-server-modules

    # System Specific modules
    ../../modules/cli/docker
    ../../modules/apps/kvm
    ../../modules/cli/helix
  ];

}
