{ user-settings, pkgs, config, lib, ... }:
let
  cfg = config.apps.vscode;
  inherit (config.lib.stylix) colors;
in {
  options = {
    apps.vscode.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the vscode editor.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.vscode
    ];
    home-manager.users."${user-settings.user.username}" = {
      # VSCode configuration with manual color integration but no font management
      programs.vscode = lib.mkIf (config.stylix.enable or false) {
        enable = true;
        profiles.default.userSettings = {
          "workbench.colorTheme" = "Default Dark Modern";
          
          # Custom color overrides using stylix colors
          "workbench.colorCustomizations" = {
            "editor.background" = "#${colors.base00}";
            "editor.foreground" = "#${colors.base05}";
            "editor.selectionBackground" = "#${colors.base02}";
            "editor.lineHighlightBackground" = "#${colors.base01}";
            "editorCursor.foreground" = "#${colors.base05}";
            "terminal.background" = "#${colors.base00}";
            "terminal.foreground" = "#${colors.base05}";
            "panel.background" = "#${colors.base00}";
            "sideBar.background" = "#${colors.base01}";
            "activityBar.background" = "#${colors.base01}";
            "statusBar.background" = "#${colors.base02}";
            "titleBar.activeBackground" = "#${colors.base01}";
            "tab.activeBackground" = "#${colors.base00}";
            "tab.inactiveBackground" = "#${colors.base01}";
          };
          
          # Terminal color palette using base16
          "terminal.integrated.ansiBlack" = "#${colors.base00}";
          "terminal.integrated.ansiRed" = "#${colors.base08}";
          "terminal.integrated.ansiGreen" = "#${colors.base0B}";
          "terminal.integrated.ansiYellow" = "#${colors.base0A}";
          "terminal.integrated.ansiBlue" = "#${colors.base0D}";
          "terminal.integrated.ansiMagenta" = "#${colors.base0E}";
          "terminal.integrated.ansiCyan" = "#${colors.base0C}";
          "terminal.integrated.ansiWhite" = "#${colors.base05}";
          "terminal.integrated.ansiBrightBlack" = "#${colors.base03}";
          "terminal.integrated.ansiBrightRed" = "#${colors.base08}";
          "terminal.integrated.ansiBrightGreen" = "#${colors.base0B}";
          "terminal.integrated.ansiBrightYellow" = "#${colors.base0A}";
          "terminal.integrated.ansiBrightBlue" = "#${colors.base0D}";
          "terminal.integrated.ansiBrightMagenta" = "#${colors.base0E}";
          "terminal.integrated.ansiBrightCyan" = "#${colors.base0C}";
          "terminal.integrated.ansiBrightWhite" = "#${colors.base07}";
        };
      };
      
      # Disable Stylix theming for VS Code to avoid font conflicts
      stylix.targets.vscode.enable = lib.mkForce false;

      # force vscode to use wayland - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer
      home.file.".config/code-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
        --enable-features=WaylandWindowDecorations
      '';
    };
  };
}
