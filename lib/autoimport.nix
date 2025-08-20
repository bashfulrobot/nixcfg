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

  # Fast recursive file discovery - single traversal
  findNixFiles = dir: 
    let
      readDirFast = path:
        let entries = builtins.readDir path; in
        concatLists (mapAttrsToList (name: type:
          let fullPath = "${path}/${name}"; in
          if type == "directory" && !(any (pattern: hasInfix pattern name) defaultExcludes)
          then readDirFast fullPath
          else if type == "regular" && hasSuffix ".nix" name && name != "imports.nix"
          then [ (removePrefix "${toString dir}/" fullPath) ]
          else []
        ) entries);
    in readDirFast (toString dir);

  # Optimized autoimport function with single traversal
  autoImport = dir: extraExcludes: trace:
    let
      allExcludes = defaultExcludes ++ extraExcludes;
      nixFiles = findNixFiles dir;
      
      # Filter out additional exclusions (already filtered defaults and .nix requirements)
      validFiles = filter (file: 
        !(any (pattern: hasInfix pattern file) extraExcludes)
      ) nixFiles;
      
      # Convert to full paths
      fullPaths = map (file: dir + "/${file}") validFiles;

      tracedFiles = if trace then
        map (file: 
          builtins.trace "Importing ${file}" file
        ) fullPaths
      else fullPaths;
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