#!/usr/bin/env bash

# softwareupdate --install-rosetta --agree-to-license

nix --extra-experimental-features flakes --extra-experimental-features nix-command run github:LnL7/nix-darwin/nix-darwin-24.11#darwin-rebuild -- switch --flake .#dustinkrysak
