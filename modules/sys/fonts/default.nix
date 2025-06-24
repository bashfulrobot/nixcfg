# TODO: Clean up fonts - what am I "actually" using?
{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.sys.fonts;
  sfpro-font = pkgs.callPackage ./build/sfpro { };
  sf-mono-liga-font = pkgs.callPackage ./build/sfpro/liga { };
  inter-font = pkgs.callPackage ./build/inter { }; # Helvetica Replacement
  aharoni-font = pkgs.callPackage ./build/aharoni { };
  # monaspace-font = pkgs.callPackage ./build/monaspace { };

in
{

  options = {
    sys.fonts.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable system fonts.";
    };
  };

  config = lib.mkIf cfg.enable {

    # fonts.fontconfig = {
    #   enable = true;
    #   defaultFonts = {
    #     serif = [ "Source Serif" "Noto Color Emoji" ];
    #     sansSerif = [ "Work Sans" "Fira Sans" "Noto Color Emoji" ];
    #     monospace = [
    #       "FiraCode Nerd Font Mono"
    #       "Font Awesome 6 Free"
    #       "Font Awesome 6 Brands"
    #       "Symbola"
    #       "Noto Emoji"
    #     ];
    #     emoji = [ "Noto Color Emoji" ];
    #   };
    # };

    # fc-list | grep [font name] -> before the ":" is the font name
    # Case sensitive
    fonts.packages = with pkgs; [
      work-sans
      aharoni-font
      inter-font
      # sfpro-font
      # sf-mono-liga-font
      font-awesome
      cantarell-fonts
      helvetica-neue-lt-std
      noto-fonts-emoji
      noto-fonts-monochrome-emoji
      source-serif
      ### nerd-fonts (25.05+ syntax)
      # if you hover over the download links on the site, the name of the zip file is the font name.
      # https://github.com/ryanoasis/nerd-fonts/releases
      nerd-fonts.fira-code
      # nerd-fonts.cascadia-code  # not available, possibly renamed
      nerd-fonts.jetbrains-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      nerd-fonts.symbols-only
      nerd-fonts.victor-mono
    ];

    home-manager.users."${user-settings.user.username}" = {

      fonts.fontconfig.enable = true;
    };
  };
}
