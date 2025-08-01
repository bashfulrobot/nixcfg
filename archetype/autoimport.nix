# Auto-import modules in this folder, recursively.
# Sourced from https://github.com/evanjs/nixos_cfg/blob/4bb5b0b84a221b25cf50853c12b9f66f0cad3ea4/config/new-modules/default.nix
{ lib, ... }:
with lib;
let
  # Recursively constructs an attrset of a given folder, recursing on directories, value of attrs is the filetype
  getDir = dir:
    mapAttrs
    (file: type: if type == "directory" then getDir "${dir}/${file}" else type)
    (builtins.readDir dir);

  # Collects all files of a directory as a list of strings of paths
  files = dir:
    collect isString
    (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  # Filters out directories that belong to home-manager, and don't end with .nix or are this file.
  # Also, make the strings absolute

# No Trace
  validFiles = dir:
    map (file: ./. + "/${file}") (filter (file:
      !hasInfix "home-manager" file && !hasInfix "build" file && !hasInfix "disabled" file && !hasInfix "module-config" file && !hasInfix "ubuntu" file && file
      != "autoimport.nix" && hasSuffix ".nix" file) (files dir));

# With Trace
# validFiles = dir:
#     map (file: let absFile = ./. + "/${file}"; in builtins.trace "Importing ${absFile} from ${builtins.dirOf absFile}" absFile)
#     (filter (file:
#       !hasInfix "home-manager" file && !hasInfix "build" file && !hasInfix "disabled" file && !hasInfix "module-config" file && !hasInfix "ubuntu" file && file
#       != "autoimport.nix" && hasSuffix ".nix" file) (files dir));

in { imports = validFiles ./.; }
