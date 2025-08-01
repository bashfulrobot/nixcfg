# Auto-import all mixed modules (system + home-manager)
{ lib, ... }:

let
  # Get the current directory
  currentDir = ./.;
  
  # Helper function to recursively find all .nix files
  findNixFiles = dir:
    let
      contents = builtins.readDir dir;
      
      # Filter function for directories and files we want to include
      shouldInclude = name: type:
        let
          # Exclude these directories entirely
          excludedDirs = [ 
            "build"           # Build outputs
            "disabled"        # Intentionally disabled modules
            ".git"            # Git directory
          ];
          
          # Exclude these files
          excludedFiles = [
            "autoimport.nix"  # Don't import ourselves
            "flake.nix"       # Flake files
          ];
          
          isExcludedDir = type == "directory" && builtins.elem name excludedDirs;
          isExcludedFile = type == "regular" && builtins.elem name excludedFiles;
          isNixFile = type == "regular" && lib.hasSuffix ".nix" name;
          isDirectory = type == "directory";
          
        in
          !isExcludedDir && !isExcludedFile && (isNixFile || isDirectory);
      
      # Get all valid entries
      validEntries = lib.filterAttrs shouldInclude contents;
      
      # Process each entry
      processEntry = name: type:
        let
          path = dir + "/${name}";
        in
          if type == "directory"
          then findNixFiles path  # Recurse into directories
          else [ path ];          # Add .nix files to the list
      
    in
      lib.flatten (lib.mapAttrsToList processEntry validEntries);
      
  # Get all .nix files in the current directory tree
  allNixFiles = findNixFiles currentDir;
  
in
{
  imports = allNixFiles;
}