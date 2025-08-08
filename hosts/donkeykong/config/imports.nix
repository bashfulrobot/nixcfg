# Auto-import host config modules using centralized autoimport function
{ lib, ... }:
let
  autoImportLib = import ../../../lib/autoimport.nix { inherit lib; };
in
autoImportLib.simpleAutoImport ./.
