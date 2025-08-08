# Auto-import archetype modules using centralized autoimport function
{ lib, ... }:
let
  autoImportLib = import ../lib/autoimport.nix { inherit lib; };
in
autoImportLib.simpleAutoImport ./.
