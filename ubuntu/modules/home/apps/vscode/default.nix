{ config, pkgs, lib, ... }:

let
  cfg = config.apps.vscode;
  inherit (config.lib.stylix) colors;
in {
  options.apps.vscode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable VSCode editor (via Home Manager)";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;

      # Use unstable channel for latest VSCode
      package = pkgs.unstable.vscode;
    };

    # Create a Stylix theme extension if Stylix is enabled
    home.file = lib.mkMerge [
      # VSCode Wayland configuration
      {
        ".config/code-flags.conf".text = ''
          --enable-features=UseOzonePlatform
          --ozone-platform=wayland
          --enable-features=WaylandWindowDecorations
        '';
      }

      # Stylix theme extension (only created when stylix is enabled)
      (lib.mkIf (config.stylix.enable or false) {
        ".vscode/extensions/stylix-theme/package.json".text = builtins.toJSON {
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

        ".vscode/extensions/stylix-theme/themes/stylix.json".text = builtins.toJSON {
          name = "Stylix";
          type = "dark";
          colors = {
            # Editor colors
            "editor.background" = "#${colors.base00}";
            "editor.foreground" = "#${colors.base05}";
            "editorCursor.foreground" = "#${colors.base0D}";
            "editor.selectionBackground" = "#${colors.base02}80";
            "editor.inactiveSelectionBackground" = "#${colors.base02}40";
            "editor.selectionForeground" = "#${colors.base07}";
            "editor.wordHighlightBackground" = "#${colors.base03}60";
            "editor.wordHighlightStrongBackground" = "#${colors.base0D}40";
            "editor.lineHighlightBackground" = "#${colors.base01}";
            "editor.lineHighlightBorder" = "#${colors.base02}";
            "editorCodeLens.foreground" = "#${colors.base04}";
            "editorInlayHint.foreground" = "#${colors.base04}";
            "editorInlayHint.background" = "#${colors.base01}";
            "editorBracketMatch.background" = "#${colors.base02}";
            "editorBracketMatch.border" = "#${colors.base0C}";
            "editorIndentGuide.background" = "#${colors.base01}";
            "editorIndentGuide.activeBackground" = "#${colors.base03}";
            "editorWhitespace.foreground" = "#${colors.base02}";
            "editorRuler.foreground" = "#${colors.base02}";
            "editor.findMatchBackground" = "#${colors.base0A}40";
            "editor.findMatchHighlightBackground" = "#${colors.base0A}20";
            "editor.findRangeHighlightBackground" = "#${colors.base02}";
            "editorError.foreground" = "#${colors.base08}";
            "editorWarning.foreground" = "#${colors.base0A}";
            "editorInfo.foreground" = "#${colors.base0D}";
            "editorHint.foreground" = "#${colors.base0C}";

            # Workbench colors
            "activityBar.background" = "#${colors.base00}";
            "activityBar.foreground" = "#${colors.base05}";
            "activityBar.inactiveForeground" = "#${colors.base03}";
            "activityBarBadge.background" = "#${colors.base0D}";
            "activityBarBadge.foreground" = "#${colors.base00}";
            "activityBar.activeBorder" = "#${colors.base0D}";
            "activityBar.activeBackground" = "#${colors.base01}";

            "sideBar.background" = "#${colors.base00}";
            "sideBar.foreground" = "#${colors.base05}";
            "sideBar.border" = "#${colors.base01}";
            "sideBarTitle.foreground" = "#${colors.base05}";
            "sideBarSectionHeader.background" = "#${colors.base01}";
            "sideBarSectionHeader.foreground" = "#${colors.base05}";

            "statusBar.background" = "#${colors.base02}";
            "statusBar.foreground" = "#${colors.base04}";
            "statusBar.debuggingBackground" = "#${colors.base08}";
            "statusBar.debuggingForeground" = "#${colors.base00}";
            "statusBar.noFolderBackground" = "#${colors.base0E}";
            "statusBar.noFolderForeground" = "#${colors.base00}";

            "titleBar.activeBackground" = "#${colors.base01}";
            "titleBar.activeForeground" = "#${colors.base05}";
            "titleBar.inactiveBackground" = "#${colors.base00}";
            "titleBar.inactiveForeground" = "#${colors.base03}";

            # Panel colors
            "panel.background" = "#${colors.base00}";
            "panel.border" = "#${colors.base02}";

            # Tab colors
            "tab.activeBackground" = "#${colors.base00}";
            "tab.activeForeground" = "#${colors.base05}";
            "tab.inactiveBackground" = "#${colors.base01}";
            "tab.inactiveForeground" = "#${colors.base04}";
            "tab.border" = "#${colors.base01}";
            "tab.activeBorder" = "#${colors.base0D}";
            "tab.unfocusedActiveBorder" = "#${colors.base03}";
            "button.background" = "#${colors.base0D}";
            "button.foreground" = "#${colors.base00}";
            "button.hoverBackground" = "#${colors.base0D}CC";
            "button.secondaryBackground" = "#${colors.base02}";
            "button.secondaryForeground" = "#${colors.base05}";
            "button.secondaryHoverBackground" = "#${colors.base03}";
            "input.background" = "#${colors.base01}";
            "input.foreground" = "#${colors.base05}";
            "input.border" = "#${colors.base02}";
            "inputOption.activeBorder" = "#${colors.base0D}";
            "dropdown.background" = "#${colors.base01}";
            "dropdown.foreground" = "#${colors.base05}";
            "dropdown.border" = "#${colors.base02}";

            # List and tree colors
            "list.activeSelectionBackground" = "#${colors.base0D}40";
            "list.activeSelectionForeground" = "#${colors.base07}";
            "list.inactiveSelectionBackground" = "#${colors.base02}";
            "list.inactiveSelectionForeground" = "#${colors.base05}";
            "list.hoverBackground" = "#${colors.base01}";
            "list.focusBackground" = "#${colors.base0D}20";
            "list.focusForeground" = "#${colors.base05}";
            "list.focusOutline" = "#${colors.base0D}";
            "list.highlightForeground" = "#${colors.base0D}";

            # Terminal colors
            "terminal.background" = "#${colors.base00}";
            "terminal.foreground" = "#${colors.base05}";
            "terminal.selectionBackground" = "#${colors.base02}80";
            "terminal.border" = "#${colors.base02}";

            # ANSI colors
            "terminal.ansiBlack" = "#${colors.base00}";
            "terminal.ansiRed" = "#${colors.base08}";
            "terminal.ansiGreen" = "#${colors.base0B}";
            "terminal.ansiYellow" = "#${colors.base0A}";
            "terminal.ansiBlue" = "#${colors.base0D}";
            "terminal.ansiMagenta" = "#${colors.base0E}";
            "terminal.ansiCyan" = "#${colors.base0C}";
            "terminal.ansiWhite" = "#${colors.base05}";

            # Bright ANSI colors
            "terminal.ansiBrightBlack" = "#${colors.base03}";
            "terminal.ansiBrightRed" = "#${colors.base08}";
            "terminal.ansiBrightGreen" = "#${colors.base0B}";
            "terminal.ansiBrightYellow" = "#${colors.base0A}";
            "terminal.ansiBrightBlue" = "#${colors.base0D}";
            "terminal.ansiBrightMagenta" = "#${colors.base0E}";
            "terminal.ansiBrightCyan" = "#${colors.base0C}";
            "terminal.ansiBrightWhite" = "#${colors.base07}";
            "terminalCursor.background" = "#${colors.base00}";
            "terminalCursor.foreground" = "#${colors.base0D}";
          };
          tokenColors = [
            {
              scope = [
                "comment"
                "punctuation.definition.comment"
                "comment.line"
                "comment.block"
                "comment.line.double-slash"
                "comment.line.number-sign"
                "comment.block.documentation"
                "comment.block.html"
                "comment.block.xml"
                "comment.line.triple-slash"
                "punctuation.definition.comment.begin"
                "punctuation.definition.comment.end"
              ];
              settings = {
                foreground = "#${colors.base04}";
                fontStyle = "italic";
              };
            }
            {
              scope = [
                "comment.block.documentation"
                "comment.line.documentation"
                "string.quoted.docstring"
              ];
              settings = {
                foreground = "#${colors.base0C}";
                fontStyle = "italic";
              };
            }
            {
              scope = [
                "comment.line.todo"
                "comment.line.fixme"
                "comment.line.hack"
                "comment.line.bug"
              ];
              settings = {
                foreground = "#${colors.base0A}";
                fontStyle = "italic bold";
              };
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
              scope = [
                "meta.object-literal.key"
                "meta.property-name.json"
                "support.type.property-name.json"
              ];
              settings.foreground = "#${colors.base0D}";
            }
            {
              scope = [
                "meta.object-literal.key meta.object-literal.key"
                "meta.property-name.json meta.property-name.json"
              ];
              settings.foreground = "#${colors.base0C}";
            }
            {
              scope = [
                "meta.object-literal.key meta.object-literal.key meta.object-literal.key"
                "meta.property-name.json meta.property-name.json meta.property-name.json"
              ];
              settings.foreground = "#${colors.base0A}";
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
          semanticHighlighting = true;
          semanticTokenColors = {
            "comment" = "#${colors.base04}";
            "comment.documentation" = "#${colors.base0C}";
          };
        };
      })
    ];

    # Set VSCode as the default editor if desired
    # home.sessionVariables.EDITOR = "code";
  };
}