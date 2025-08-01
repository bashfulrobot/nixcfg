{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.fonts;

in
{
  options.sys.fonts = {
    enable = lib.mkEnableOption "Enable curated font collection including Nerd Fonts and productivity fonts";
  };

  config = lib.mkIf cfg.enable {
    # Install fonts via home-manager packages
    home.packages = with pkgs; [
      work-sans
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