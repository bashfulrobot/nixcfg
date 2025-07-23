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
          "activityBar.background" = "#${colors.base00}";
          "activityBar.foreground" = "#${colors.base05}";
          "sideBar.background" = "#${colors.base00}";
          "sideBar.foreground" = "#${colors.base05}";
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
        tokenColors = [
          {
            scope = ["comment" "punctuation.definition.comment"];
            settings.foreground = "#${colors.base03}";
          }
          {
            scope = ["constant" "entity.name.constant" "variable.other.constant" "variable.language"];
            settings.foreground = "#${colors.base09}";
          }
          {
            scope = ["entity" "entity.name"];
            settings.foreground = "#${colors.base0A}";
          }
          {
            scope = "variable.parameter.function";
            settings.foreground = "#${colors.base05}";
          }
          {
            scope = "entity.name.tag";
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = "keyword";
            settings.foreground = "#${colors.base0E}";
          }
          {
            scope = ["storage" "storage.type"];
            settings.foreground = "#${colors.base0E}";
          }
          {
            scope = ["storage.modifier.package" "storage.modifier.import" "storage.type.java"];
            settings.foreground = "#${colors.base05}";
          }
          {
            scope = ["string" "punctuation.definition.string" "string punctuation.section.embedded source"];
            settings.foreground = "#${colors.base0B}";
          }
          {
            scope = "support";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = "meta.property-name";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = "variable";
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = "variable.other";
            settings.foreground = "#${colors.base05}";
          }
          {
            scope = "invalid.broken";
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = "invalid.deprecated";
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = "invalid.illegal";
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = "invalid.unimplemented";
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = "carriage-return";
            settings = {
              foreground = "#${colors.base00}";
              background = "#${colors.base08}";
            };
          }
          {
            scope = "message.error";
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = "string source";
            settings.foreground = "#${colors.base05}";
          }
          {
            scope = "string variable";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = ["source.regexp" "string.regexp"];
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = ["string.regexp.character-class" "string.regexp constant.character.escape" "string.regexp source.ruby.embedded" "string.regexp string.regexp.arbitrary-repitition"];
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = "string.regexp constant.character.escape";
            settings.foreground = "#${colors.base0A}";
          }
          {
            scope = "support.constant";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = "support.variable";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = "meta.module-reference";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = "punctuation.definition.list.begin.markdown";
            settings.foreground = "#${colors.base09}";
          }
          {
            scope = ["markup.heading" "markup.heading entity.name"];
            settings = {
              fontStyle = "bold";
              foreground = "#${colors.base0C}";
            };
          }
          {
            scope = "markup.quote";
            settings.foreground = "#${colors.base0A}";
          }
          {
            scope = "markup.italic";
            settings = {
              fontStyle = "italic";
              foreground = "#${colors.base05}";
            };
          }
          {
            scope = "markup.bold";
            settings = {
              fontStyle = "bold";
              foreground = "#${colors.base05}";
            };
          }
          {
            scope = "markup.raw";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = ["markup.deleted" "meta.diff.header.from-file" "punctuation.definition.deleted"];
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = ["markup.inserted" "meta.diff.header.to-file" "punctuation.definition.inserted"];
            settings.foreground = "#${colors.base0B}";
          }
          {
            scope = ["markup.changed" "punctuation.definition.changed"];
            settings.foreground = "#${colors.base09}";
          }
          {
            scope = ["markup.ignored" "markup.untracked"];
            settings.foreground = "#${colors.base01}";
          }
          {
            scope = "meta.diff.range";
            settings.foreground = "#${colors.base0E}";
          }
          {
            scope = "meta.diff.header";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = "meta.separator";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = "meta.output";
            settings.foreground = "#${colors.base0C}";
          }
          {
            scope = ["brackethighlighter.tag" "brackethighlighter.curly" "brackethighlighter.round" "brackethighlighter.square" "brackethighlighter.angle" "brackethighlighter.quote"];
            settings.foreground = "#${colors.base03}";
          }
          {
            scope = "brackethighlighter.unmatched";
            settings.foreground = "#${colors.base08}";
          }
          {
            scope = ["constant.other.reference.link" "string.other.link"];
            settings.foreground = "#${colors.base0C}";
          }
        ];
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
