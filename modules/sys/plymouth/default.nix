{ config, pkgs, lib, user-settings, ... }:
let
  cfg = config.sys.plymouth;
  plymouthIcon = pkgs.callPackage ./build/icon.nix {};

  # Get colors from stylix
  inherit (config.lib.stylix) colors;
  
  # Use wallpaper module if enabled, otherwise fallback to old method
  plymouthLogo = if config.sys.wallpapers.enable
                 then 
                   let
                     wallpaperPath = config.sys.wallpapers.getPlymouthBackground cfg.backgroundType;
                   in
                   if wallpaperPath != ""
                   then wallpaperPath
                   else "${plymouthIcon}/share/icons/hicolor/48x48/apps/plymouth.png"
                 else
                   let
                     # Fallback: original plymouth background logic
                     getPlymouthBackground = backgroundType:
                       if backgroundType == "personal" && (user-settings.theme ? personal-plymouth-background) && user-settings.theme.personal-plymouth-background != ""
                       then user-settings.theme.personal-plymouth-background
                       else if backgroundType == "professional" && (user-settings.theme ? professional-plymouth-background) && user-settings.theme.professional-plymouth-background != ""
                       then user-settings.theme.professional-plymouth-background
                       else "";
                     
                     plymouthBackgroundSetting = getPlymouthBackground cfg.backgroundType;
                     customPlymouthPath = if plymouthBackgroundSetting != "" 
                                         then "${user-settings.user.home}/Pictures/Wallpapers/${builtins.baseNameOf plymouthBackgroundSetting}"
                                         else "";
                   in
                   if plymouthBackgroundSetting != "" && builtins.pathExists customPlymouthPath
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
      font = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFontMono-Regular.ttf";
      logo = plymouthLogo;
      extraConfig = ''
        ShowDelay=0
        DeviceScale=2
        BackgroundStartColor=0x${colors.base00}
        BackgroundEndColor=0x${colors.base01}
        TextColor=0x${colors.base05}
        ProgressBarBackgroundColor=0x${colors.base01}
        ProgressBarForegroundColor=0x${colors.base0D}
        PasswordCharacter=*
        UseProgressBar=true
        UseAnimation=true
      '';
    };

    # Ensure Plymouth handles disk encryption prompts
    boot.initrd.systemd.enable = true;

  };
}