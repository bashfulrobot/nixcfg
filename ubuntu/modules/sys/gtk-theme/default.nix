{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.gtk-theme;
in
{
  options.sys.gtk-theme = {
    enable = lib.mkEnableOption "GTK theming support for stylix (home-manager only)";
  };

  config = lib.mkIf cfg.enable {
    # Install GTK packages via home-manager
    home.packages = with pkgs; [
      gtk-engine-murrine
      gtk3
      gtk4
    ];

    # GTK theming configuration
    gtk = {
      enable = true;
      
      # Let stylix handle theme, icon, and cursor configuration

      # GTK settings
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-button-images = false;
        gtk-menu-images = false;
        gtk-primary-button-warps-slider = false;
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH_HORIZ";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-decoration-layout = "close,minimize,maximize:";
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-decoration-layout = "close,minimize,maximize:";
      };
    };

    # Qt theme to match GTK - using mkDefault to allow stylix to override
    qt = {
      enable = true;
      platformTheme.name = lib.mkDefault "adwaita";
      style.name = lib.mkDefault "adwaita-dark";
    };

    # dconf settings for GNOME integration
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
}