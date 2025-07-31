{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.fonts;
  
  # Load custom font packages from parent directory
  sfpro-font = pkgs.callPackage ../../../modules/sys/fonts/build/sfpro { };
  sf-mono-liga-font = pkgs.callPackage ../../../modules/sys/fonts/build/sfpro/liga { };
  inter-font = pkgs.callPackage ../../../modules/sys/fonts/build/inter { };
  aharoni-font = pkgs.callPackage ../../../modules/sys/fonts/build/aharoni { };
  # monaspace-font = pkgs.callPackage ../../../modules/sys/fonts/build/monaspace { };
in
{
  options.sys.fonts = {
    enable = lib.mkEnableOption "System fonts (home-manager only)";
  };

  config = lib.mkIf cfg.enable {
    # Install fonts via home-manager packages
    home.packages = with pkgs; [
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
      nerd-fonts.caskaydia-cove
      nerd-fonts.jetbrains-mono
      nerd-fonts.sauce-code-pro
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      nerd-fonts.ubuntu-sans
      nerd-fonts.symbols-only
      nerd-fonts.victor-mono
    ];

    # Enable fontconfig for proper font handling
    fonts.fontconfig.enable = true;
  };
}