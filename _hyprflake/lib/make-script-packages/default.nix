{ pkgs, lib }:

{
  # Directory containing the .sh files (required - must be passed explicitly)
  scriptsDir,

  # List of script names (without .sh extension) or attribute sets with configuration
  # Examples:
  #   scripts = [ "script1" "script2" ];
  #   scripts = [ "script1" { name = "script2"; command = "custom-cmd"; } ];
  #   scripts = [ { name = "script3"; runtimeInputs = [ pkgs.curl pkgs.jq ]; } ];
  scripts,

  # Whether to create fish shell abbreviations (optional)
  createFishAbbrs ? true,

  # Global script-to-command mapping (optional, overridden by per-script command)
  scriptMap ? {},

  # Global runtime dependencies for all scripts (optional)
  # When specified, scripts will use writeShellApplication instead of writeShellScriptBin
  runtimeInputs ? []
}:

let
  # Normalize script entries to attribute sets
  normalizeScript = script:
    if builtins.isString script then
      {
        name = script;
        command = scriptMap.${script} or script;
        runtimeInputs = [];
      }
    else
      script // {
        command = script.command or (scriptMap.${script.name} or script.name);
        runtimeInputs = script.runtimeInputs or [];
      };

  # Convert all scripts to normalized form
  normalizedScripts = builtins.map normalizeScript scripts;

  # Create a script package from a normalized script entry
  makeScript = scriptConfig:
    let
      scriptFile = "${scriptsDir}/${scriptConfig.name}.sh";
      commandName = scriptConfig.command;
      # Merge global and per-script runtimeInputs
      allRuntimeInputs = runtimeInputs ++ scriptConfig.runtimeInputs;
      hasRuntimeInputs = builtins.length allRuntimeInputs > 0;
    in
    if builtins.pathExists scriptFile then
      if hasRuntimeInputs then
        pkgs.writeShellApplication {
          name = commandName;
          runtimeInputs = allRuntimeInputs;
          text = builtins.readFile scriptFile;
        }
      else
        pkgs.writeShellScriptBin commandName (builtins.readFile scriptFile)
    else
      throw "Script file not found: ${scriptFile}";

  # Generate all script packages
  scriptPackages = builtins.map makeScript normalizedScripts;

  # Generate fish abbreviations if requested
  fishAbbrs = lib.optionalAttrs createFishAbbrs
    (builtins.listToAttrs 
      (builtins.map (script: { name = script.command; value = script.command; }) normalizedScripts));

in {
  # Script packages ready for environment.systemPackages
  packages = scriptPackages;

  # Fish shell abbreviations ready for programs.fish.shellAbbrs
  fishShellAbbrs = fishAbbrs;

  # Convenience: just the script names (useful for debugging)
  scriptNames = builtins.map (script: script.name) normalizedScripts;
  commandNames = builtins.map (script: script.command) normalizedScripts;
}