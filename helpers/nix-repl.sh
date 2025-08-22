#!/bin/bash

cd ~/dev/nix/nixcfg

nix repl --expr '
  let
    flake = builtins.getFlake (toString ./.);
    hostname = "'$(hostname)'";
    username = "'$(whoami)'";
  in {
    inherit flake;
    config = flake.nixosConfigurations.${hostname}.config;
    options = flake.nixosConfigurations.${hostname}.options;
    homeManagerConfig = flake.nixosConfigurations.${hostname}.config.home-manager.users.${username};
  }'
