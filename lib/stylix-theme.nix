{ lib, ... }:
let
  inherit (builtins) readFile;
  inherit (lib) replaceStrings;
in
{
  # Theme Substituter - based on maydayv7/dotfiles implementation
  build = {
    accent ? "base0D",
    colors ? null,
    fonts ? null,
    file,
    iconsPath ? null,
  }:
  let
    colorPlaceholders = [
      "@accent"
      "@white"
      "@base00"
      "@base01"
      "@base02"
      "@base03"
      "@base04"
      "@base05"
      "@base06"
      "@base07"
      "@base08"
      "@base09"
      "@base0A"
      "@base0B"
      "@base0C"
      "@base0D"
      "@base0E"
      "@base0F"
    ];

    colorValues = with colors; [
      colors."${accent}"
      "FFFFFF"
      base00
      base01
      base02
      base03
      base04
      base05
      base06
      base07
      base08
      base09
      base0A
      base0B
      base0C
      base0D
      base0E
      base0F
    ];

    fontPlaceholders = [
      "@font"
      "@monospace"
    ];

    fontValues = with fonts; [
      sansSerif.name
      monospace.name
    ];

    iconPlaceholders = [ "@iconsPath@" ];
    iconValues = [ iconsPath ];

    # Combine all placeholders and values
    allPlaceholders =
      (if colors != null then colorPlaceholders else []) ++
      (if fonts != null then fontPlaceholders else []) ++
      (if iconsPath != null then iconPlaceholders else []);

    allValues =
      (if colors != null then colorValues else []) ++
      (if fonts != null then fontValues else []) ++
      (if iconsPath != null then iconValues else []);

  in
  if (colors != null || fonts != null || iconsPath != null) then
    replaceStrings allPlaceholders allValues file
  else
    throw "At least one of 'colors', 'fonts', or 'iconsPath' must be declared";
}