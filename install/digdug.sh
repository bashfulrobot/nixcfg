#!/usr/bin/env bash
git clone https://github.com/bashfulrobot/nixcfg
cd nixcfg
sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko/latest#disko-install -- --flake .#digdug --disk main /dev/nvme0n1

