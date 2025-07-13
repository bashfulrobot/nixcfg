{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.sys.dracula-theme;
  # Official Dracula color palette
  dracula-colors = {
    background = "#282a36";
    current-line = "#44475a";
    selection = "#44475a";
    foreground = "#f8f8f2";
    comment = "#6272a4";
    cyan = "#8be9fd";
    green = "#50fa7b";
    orange = "#ffb86c";
    pink = "#ff79c6";
    purple = "#bd93f9";
    red = "#ff5555";
    yellow = "#f1fa8c";
    # Additional colors for UI elements
    surface = "#44475a";
    text = "#f8f8f2";
    accent = "#bd93f9";
    border-active = "#bd93f9";
    border-inactive = "#6272a4";
  };
in
{
  options.sys.dracula-theme = {
    enable = lib.mkEnableOption "Dracula dark theme";
  };

  config = lib.mkIf cfg.enable {
    # GNOME desktop theme
    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Adwaita-dark";
          icon-theme = "Papirus-Dark";
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

    # System-wide GTK configuration with Dracula colors
    environment.sessionVariables = {
      GTK_THEME = "Adwaita-dark";
      THEME_COLORS_BACKGROUND = dracula-colors.background;
      THEME_COLORS_SURFACE = dracula-colors.surface;
      THEME_COLORS_TEXT = dracula-colors.text;
      THEME_COLORS_ACCENT = dracula-colors.accent;
      THEME_COLORS_BORDER_ACTIVE = dracula-colors.border-active;
      THEME_COLORS_BORDER_INACTIVE = dracula-colors.border-inactive;
      # Additional Dracula colors for applications
      DRACULA_BACKGROUND = dracula-colors.background;
      DRACULA_FOREGROUND = dracula-colors.foreground;
      DRACULA_PURPLE = dracula-colors.purple;
      DRACULA_PINK = dracula-colors.pink;
      DRACULA_CYAN = dracula-colors.cyan;
      DRACULA_GREEN = dracula-colors.green;
      DRACULA_ORANGE = dracula-colors.orange;
      DRACULA_RED = dracula-colors.red;
      DRACULA_YELLOW = dracula-colors.yellow;
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
          name = lib.mkDefault "Papirus-Dark";
          package = lib.mkDefault pkgs.papirus-icon-theme;
        };
        cursorTheme = {
          name = lib.mkDefault "Adwaita";
          package = lib.mkDefault pkgs.adwaita-icon-theme;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = lib.mkDefault "Adwaita-dark";
          icon-theme = lib.mkDefault "Papirus-Dark";
          cursor-theme = lib.mkDefault "Adwaita";
          color-scheme = lib.mkDefault "prefer-dark";
        };
        "org/gnome/desktop/wm/preferences" = {
          theme = lib.mkDefault "Adwaita-dark";
        };
      };

      # Terminal theming
      programs.kitty = {
        themeFile = "Dracula";
      };

      # Configure applications to use dark theme preference
      programs.firefox.profiles.default.settings = {
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.dark-private-windows" = true;
      };

      # Create Dracula color scheme for rofi
      xdg.configFile."rofi/colors/dracula.rasi".text = ''
        * {
            bg-col:  ${dracula-colors.background};
            bg-col-light: ${dracula-colors.surface};
            border-col: ${dracula-colors.border-active};
            selected-col: ${dracula-colors.selection};
            blue: ${dracula-colors.cyan};
            fg-col: ${dracula-colors.text};
            fg-col2: ${dracula-colors.accent};
            grey: ${dracula-colors.border-inactive};

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
            "col.active_border" = lib.mkDefault "rgba(bd93f9ee)"; # Dracula purple
            "col.inactive_border" = lib.mkDefault "rgba(6272a4aa)"; # Dracula comment
          };
          group = {
            "col.border_active" = lib.mkDefault "rgba(bd93f9ee)";
            "col.border_inactive" = lib.mkDefault "rgba(6272a4aa)";
            "col.border_locked_active" = lib.mkDefault "rgba(ff79c6ee)"; # Dracula pink
            "col.border_locked_inactive" = lib.mkDefault "rgba(6272a4aa)";
          };
        };
      };

      # Additional Dracula theming for various applications
      programs.git.extraConfig = {
        color = {
          ui = "auto";
          branch = {
            current = "cyan bold";
            local = "white";
            remote = "magenta";
          };
          diff = {
            meta = "yellow bold";
            frag = "magenta bold";
            old = "red bold";
            new = "green bold";
          };
          status = {
            added = "green";
            changed = "yellow";
            untracked = "cyan";
          };
        };
      };

      # Bat (cat replacement) with Dracula theme
      programs.bat = {
        config = {
          theme = lib.mkDefault "Dracula";
        };
      };

      # Zellij terminal multiplexer theming
      programs.zellij = lib.mkIf config.cli.zellij.enable {
        settings = {
          theme = lib.mkDefault "dracula";
        };
      };
    };

    # Install necessary packages
    environment.systemPackages = with pkgs; [
      gnome-themes-extra
      adwaita-icon-theme
      papirus-icon-theme
    ];
  };
}