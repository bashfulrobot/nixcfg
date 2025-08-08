{ config, pkgs, lib, user-settings, ... }:
let 
  cfg = config.sys.plymouth;
  plymouthIcon = pkgs.callPackage ./build/icon.nix {};
  
  # Determine which Plymouth background to use based on the backgroundType option
  getPlymouthBackground = backgroundType:
    if backgroundType == "personal" && (user-settings.theme ? personal-plymouth-background) && user-settings.theme.personal-plymouth-background != ""
    then user-settings.theme.personal-plymouth-background
    else if backgroundType == "professional" && (user-settings.theme ? professional-plymouth-background) && user-settings.theme.professional-plymouth-background != ""
    then user-settings.theme.professional-plymouth-background
    else "";  # empty string means use default (unconfigured)
    
  plymouthBackgroundSetting = getPlymouthBackground cfg.backgroundType;
  customPlymouthPath = if plymouthBackgroundSetting != "" 
                      then "${user-settings.user.home}/Pictures/Wallpapers/${builtins.baseNameOf plymouthBackgroundSetting}"
                      else "";
  
  # Determine Plymouth logo path: custom background first, then default icon
  # Copy custom background to Nix store if it exists, similar to stylix-theme module
  plymouthLogo = if plymouthBackgroundSetting != "" && builtins.pathExists customPlymouthPath
                then builtins.path {
                  path = customPlymouthPath;
                  name = builtins.baseNameOf plymouthBackgroundSetting;
                }
                else "${plymouthIcon}/share/icons/hicolor/48x48/apps/plymouth.png";
in {

  options = {
    sys.plymouth.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Plymouth.";
    };
    sys.plymouth.backgroundType = lib.mkOption {
      type = lib.types.enum [ "unconfigured" "personal" "professional" ];
      default = "unconfigured";
      description = "Which Plymouth background type to use: unconfigured (default), personal, or professional";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      plymouthIcon
    ];
    boot.plymouth = {
      enable = true;
      theme = "bgrt";  # Use bgrt theme which supports logos and encryption prompts
      font = "${pkgs.work-sans}/share/fonts/opentype/WorkSans-Regular.ttf";
      logo = plymouthLogo;
      extraConfig = ''
        ShowDelay=0
        DeviceScale=2
      '';
    };

    # Ensure Plymouth handles disk encryption prompts
    boot.initrd.systemd.enable = true;

  };
}
