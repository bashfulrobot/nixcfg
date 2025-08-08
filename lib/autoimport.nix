# Centralized autoimport function
# Provides a reusable function to recursively import all .nix files from a directory
# with customizable exclusion patterns
{ lib }:

with lib;
let
  # Default exclusions that apply to all directories
  defaultExcludes = [
    "home-manager"
    "build" 
    "disabled"
    "module-config"
    "ubuntu"
  ];

  # Recursively constructs an attrset of a given folder, recursing on directories
  getDir = dir:
    mapAttrs
    (file: type: if type == "directory" then getDir "${dir}/${file}" else type)
    (builtins.readDir dir);

  # Collects all files of a directory as a list of strings of paths
  files = dir:
    collect isString
    (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  # Core autoimport function
  # dir: directory to import from (path)
  # extraExcludes: additional patterns to exclude (list of strings)
  # trace: whether to enable trace output for debugging (bool)
  autoImport = dir: extraExcludes: trace:
    let
      allExcludes = defaultExcludes ++ extraExcludes;
      
      validFiles = map (file: dir + "/${file}") 
        (filter (file:
          # Check if file should be excluded
          !(any (pattern: hasInfix pattern file) allExcludes) &&
          # Must be a .nix file
          hasSuffix ".nix" file &&
          # Don't import imports.nix itself  
          file != "imports.nix"
        ) (files dir));

      tracedFiles = if trace then
        map (file: 
          builtins.trace "Importing ${file} from ${builtins.dirOf file}" file
        ) validFiles
      else validFiles;
    in
      { imports = tracedFiles; };

in {
  # Main function: autoImport directory with optional exclusions
  # Usage: autoImport ./path/to/modules [] false
  inherit autoImport;
  
  # Convenience functions for common use cases
  
  # Simple autoimport with no extra exclusions
  # Usage: simpleAutoImport ./modules
  simpleAutoImport = dir: autoImport dir [] false;
  
  # Autoimport with trace enabled for debugging
  # Usage: tracedAutoImport ./modules [] 
  tracedAutoImport = dir: extraExcludes: autoImport dir extraExcludes true;
  
  # Autoimport with custom exclusions
  # Usage: customAutoImport ./modules ["custom-exclude" "another-exclude"]
  customAutoImport = dir: extraExcludes: autoImport dir extraExcludes false;
}