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
      # Original working approach: no programs.vscode management - let settings sync work
      
      # Generate Stylix VSCode theme extension
      home.file.".vscode/extensions/stylix-theme/package.json".text = builtins.toJSON {
        name = "stylix-theme";
        displayName = "Stylix Theme";
        description = "Auto-generated theme from Stylix colors";
        version = "1.0.0";
        engines.vscode = "^1.0.0";
        categories = [ "Themes" ];
        contributes.themes = [{
          label = "Stylix";
          uiTheme = "vs-dark";
          path = "./themes/stylix.json";
        }];
      };
      
      home.file.".vscode/extensions/stylix-theme/themes/stylix.json".text = lib.mkIf (config.stylix.enable or false) (builtins.toJSON {
        name = "Stylix";
        type = "dark";
        colors = {
          # Editor colors
          "editor.background" = "#${colors.base00}";
          "editor.foreground" = "#${colors.base05}";
          "editor.selectionBackground" = "#${colors.base02}";
          "editor.lineHighlightBackground" = "#${colors.base01}";
          "editorCursor.foreground" = "#${colors.base05}";
          
          # Workbench colors
          "activityBar.background" = "#${colors.base01}";
          "activityBar.foreground" = "#${colors.base05}";
          "sideBar.background" = "#${colors.base01}";
          "sideBar.foreground" = "#${colors.base04}";
          "statusBar.background" = "#${colors.base02}";
          "statusBar.foreground" = "#${colors.base04}";
          "titleBar.activeBackground" = "#${colors.base01}";
          "titleBar.activeForeground" = "#${colors.base05}";
          
          # Panel colors
          "panel.background" = "#${colors.base00}";
          "panel.border" = "#${colors.base02}";
          
          # Tab colors
          "tab.activeBackground" = "#${colors.base00}";
          "tab.activeForeground" = "#${colors.base05}";
          "tab.inactiveBackground" = "#${colors.base01}";
          "tab.inactiveForeground" = "#${colors.base04}";
          
          # Terminal colors
          "terminal.background" = "#${colors.base00}";
          "terminal.foreground" = "#${colors.base05}";
          "terminal.ansiBlack" = "#${colors.base00}";
          "terminal.ansiRed" = "#${colors.base08}";
          "terminal.ansiGreen" = "#${colors.base0B}";
          "terminal.ansiYellow" = "#${colors.base0A}";
          "terminal.ansiBlue" = "#${colors.base0D}";
          "terminal.ansiMagenta" = "#${colors.base0E}";
          "terminal.ansiCyan" = "#${colors.base0C}";
          "terminal.ansiWhite" = "#${colors.base05}";
          "terminal.ansiBrightBlack" = "#${colors.base03}";
          "terminal.ansiBrightRed" = "#${colors.base08}";
          "terminal.ansiBrightGreen" = "#${colors.base0B}";
          "terminal.ansiBrightYellow" = "#${colors.base0A}";
          "terminal.ansiBrightBlue" = "#${colors.base0D}";
          "terminal.ansiBrightMagenta" = "#${colors.base0E}";
          "terminal.ansiBrightCyan" = "#${colors.base0C}";
          "terminal.ansiBrightWhite" = "#${colors.base07}";
        };
      });

      # force vscode to use wayland - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer
      home.file.".config/code-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
        --enable-features=WaylandWindowDecorations
      '';
    };
  };
}
