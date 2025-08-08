{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.wallpapers;
  
  # Build wallpaper packages from repo files
  buildWallpaperPackage = name: fileName:
    let
      wallpaperPath = ./build + "/${fileName}";
    in
    if builtins.pathExists wallpaperPath
    then pkgs.stdenvNoCC.mkDerivation {
      name = "${name}-wallpaper";
      dontConfigure = true;
      
      src = wallpaperPath;
      
      unpackPhase = "true"; # Skip unpacking since src is a single file
      
      installPhase = ''
        mkdir -p $out/share/wallpapers
        cp $src $out/share/wallpapers/${fileName}
      '';
      
      meta = with lib; {
        description = "Custom wallpaper: ${name}";
        maintainers = [ ];
      };
    }
    else null;
  
  # Get wallpaper settings from user-settings
  personalWallpaper = user-settings.theme.personal-wallpaper or null;
  professionalWallpaper = user-settings.theme.professional-wallpaper or null;
  personalPlymouthBackground = user-settings.theme.personal-plymouth-background or null;
  professionalPlymouthBackground = user-settings.theme.professional-plymouth-background or null;
  
  # Build wallpaper packages
  personalWallpaperPkg = if personalWallpaper != null 
    then buildWallpaperPackage "personal" personalWallpaper 
    else null;
  professionalWallpaperPkg = if professionalWallpaper != null 
    then buildWallpaperPackage "professional" professionalWallpaper 
    else null;
  personalPlymouthPkg = if personalPlymouthBackground != null 
    then buildWallpaperPackage "personal-plymouth" personalPlymouthBackground 
    else null;
  professionalPlymouthPkg = if professionalPlymouthBackground != null 
    then buildWallpaperPackage "professional-plymouth" professionalPlymouthBackground 
    else null;
  
  # Filter out null packages
  wallpaperPackages = builtins.filter (pkg: pkg != null) [
    personalWallpaperPkg
    professionalWallpaperPkg
    personalPlymouthPkg
    professionalPlymouthPkg
  ];
  
  # Helper function to get wallpaper from packages
  getWallpaperPath = wallpaperType: fileName:
    let
      # Find package that contains the wallpaper type
      matchingPkgs = builtins.filter 
        (pkg: pkg != null && builtins.match ".*${wallpaperType}.*" pkg.name != null) 
        wallpaperPackages;
      matchingPkg = if matchingPkgs != [] then builtins.head matchingPkgs else null;
    in
    if matchingPkg != null
    then "${matchingPkg}/share/wallpapers/${fileName}"
    else "${pkgs.gnome-backgrounds}/share/backgrounds/gnome/${fileName}";

in
{
  options.sys.wallpapers = {
    enable = lib.mkEnableOption "Custom wallpaper packages";
    
    getWallpaper = lib.mkOption {
      type = lib.types.functionTo lib.types.str;
      readOnly = true;
      description = "Function to get wallpaper path by type (personal/professional)";
      default = wallpaperType:
        let
          fileName = if wallpaperType == "personal" && personalWallpaper != null
                     then personalWallpaper
                     else if wallpaperType == "professional" && professionalWallpaper != null
                     then professionalWallpaper
                     else if personalWallpaper != null
                     then personalWallpaper
                     else "adwaita-d.jpg";
        in
        if cfg.enable then getWallpaperPath wallpaperType fileName
        else "${pkgs.gnome-backgrounds}/share/backgrounds/gnome/${fileName}";
    };
    
    getPlymouthBackground = lib.mkOption {
      type = lib.types.functionTo lib.types.str;
      readOnly = true;
      description = "Function to get Plymouth background path by type (personal/professional)";
      default = backgroundType:
        let
          fileName = if backgroundType == "personal" && personalPlymouthBackground != null
                     then personalPlymouthBackground
                     else if backgroundType == "professional" && professionalPlymouthBackground != null
                     then professionalPlymouthBackground
                     else "";
        in
        if cfg.enable && fileName != "" then getWallpaperPath ("${backgroundType}-plymouth") fileName
        else "";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install wallpaper packages
    environment.systemPackages = wallpaperPackages;
  };
}