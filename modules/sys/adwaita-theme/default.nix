{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.adwaita-theme;
  # Adwaita color palette for consistency
  adwaita-colors = {
    background = "#1e1e1e";
    surface = "#2d2d2d";
    text = "#ffffff";
    accent = "#78aeed";
    border-active = "#78aeed";
    border-inactive = "#4a4a4a";
  };
in
{
  options.sys.adwaita-theme = {
    enable = lib.mkEnableOption "Adwaita dark theme";
  };

  config = lib.mkIf cfg.enable {
    # GNOME desktop theme
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita-dark";
          icon-theme = "Adwaita";
          cursor-theme = "Adwaita";
          color-scheme = "prefer-dark";
        };
        "org/gnome/desktop/wm/preferences" = {
          theme = "Adwaita-dark";
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
        };
      };
    }];

    # System-wide GTK configuration
    environment.sessionVariables = {
      GTK_THEME = "Adwaita-dark";
      THEME_COLORS_BACKGROUND = adwaita-colors.background;
      THEME_COLORS_SURFACE = adwaita-colors.surface;
      THEME_COLORS_TEXT = adwaita-colors.text;
      THEME_COLORS_ACCENT = adwaita-colors.accent;
      THEME_COLORS_BORDER_ACTIVE = adwaita-colors.border-active;
      THEME_COLORS_BORDER_INACTIVE = adwaita-colors.border-inactive;
    };

    # Home-manager configuration for consistent theming
    home-manager.users."${user-settings.user.username}" = {
      gtk = {
        enable = true;
        theme = {
          name = lib.mkDefault "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
        iconTheme = {
          name = lib.mkDefault "Adwaita";
          package = lib.mkDefault pkgs.adwaita-icon-theme;
        };
        cursorTheme = {
          name = lib.mkDefault "Adwaita";
          package = lib.mkDefault pkgs.adwaita-icon-theme;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = lib.mkDefault "Adwaita-dark";
          icon-theme = lib.mkDefault "Adwaita";
          cursor-theme = lib.mkDefault "Adwaita";
          color-scheme = lib.mkDefault "prefer-dark";
        };
        "org/gnome/desktop/wm/preferences" = {
          theme = lib.mkDefault "Adwaita-dark";
        };
      };

      # Terminal theming (for applications that support it)
      programs.kitty = {
        themeFile = "adwaita_dark";
      };

      # Configure applications to use dark theme preference
      programs.firefox.profiles.default.settings = {
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.dark-private-windows" = true;
      };

      # Create Adwaita color scheme for rofi
      xdg.configFile."rofi/colors/adwaita.rasi".text = ''
        * {
            bg-col:  ${adwaita-colors.background};
            bg-col-light: ${adwaita-colors.surface};
            border-col: ${adwaita-colors.border-active};
            selected-col: ${adwaita-colors.surface};
            blue: ${adwaita-colors.accent};
            fg-col: ${adwaita-colors.text};
            fg-col2: ${adwaita-colors.accent};
            grey: ${adwaita-colors.border-inactive};

            width: 600;
            font: "JetBrainsMono Nerd Font 14";
        }
      '';

      # Hyprland theming integration
      wayland.windowManager.hyprland = lib.mkIf config.desktops.tiling.hyprland.enable {
        settings = {
          env = [
            "GTK_THEME,Adwaita-dark"
          ];
          general = {
            "col.active_border" = lib.mkDefault "rgba(78aeeeee)"; # Adwaita blue
            "col.inactive_border" = lib.mkDefault "rgba(4a4a4aaa)"; # Adwaita gray
          };
          group = {
            "col.border_active" = lib.mkDefault "rgba(78aeeeee)";
            "col.border_inactive" = lib.mkDefault "rgba(4a4a4aaa)";
            "col.border_locked_active" = lib.mkDefault "rgba(78aeeeee)";
            "col.border_locked_inactive" = lib.mkDefault "rgba(4a4a4aaa)";
          };
        };
      };
    };

    # Install necessary packages
    environment.systemPackages = with pkgs; [
      gnome-themes-extra
      adwaita-icon-theme
    ];
  };
}