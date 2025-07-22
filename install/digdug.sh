#!/usr/bin/env bash
git clone https://github.com/bashfulrobot/nixcfg
cd nixcfg
read -p "in another terminal, run git-crypt unlock, then press enter"
sudo nix --extra-experimental-features nix-command --extra-experimental-features flakes run github:nix-community/disko/latest#disko-install -- --flake .#donkey-kong --disk main /dev/nvme0n1
