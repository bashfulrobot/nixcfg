{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.satty;
  inherit (config.lib.stylix) colors;

in
{

  options = {
    apps.satty.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Satty screenshot annotation tool.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      unstable.satty
      # keep-sorted end
    ];

    home-manager.users."${user-settings.user.username}" = {
      xdg.configFile."satty/config.toml".text = ''
        [general]
        # Start Satty in fullscreen mode
        fullscreen = true
        # Exit directly after copy/save action
        early-exit = false
        # Draw corners of rectangles round if the value is greater than 0 (0 disables rounded corners)
        corner-roundness = 12
        # Select the tool on startup [possible values: pointer, crop, line, arrow, rectangle, text, marker, blur, brush]
        initial-tool = "arrow"
        # Configure the command to be called on copy, for example `wl-copy`
        copy-command = "wl-copy"
        # Increase or decrease the size of the annotations
        annotation-size-factor = 2
        # Filename to use for saving action. Omit to disable saving to file. Might contain format specifiers: https://docs.rs/chrono/latest/chrono/format/strftime/index.html
        output-filename = "${user-settings.user.home}/Pictures/Screenshots/satty-%Y-%m-%d_%H:%M:%S.png"
        # After copying the screenshot, save it to a file as well
        save-after-copy = false
        # Hide toolbars by default
        default-hide-toolbars = false
        # The primary highlighter to use, the other is accessible by holding CTRL at the start of a highlight [possible values: block, freehand]
        primary-highlighter = "block"
        # Disable notifications
        disable-notifications = false
        # Actions to trigger on right click (order is important)
        # [possible values: save-to-clipboard, save-to-file, exit]
        actions-on-right-click = []
        # Actions to trigger on Enter key (order is important)
        # [possible values: save-to-clipboard, save-to-file, exit]
        actions-on-enter = ["save-to-clipboard"]
        # Actions to trigger on Escape key (order is important)
        # [possible values: save-to-clipboard, save-to-file, exit]
        actions-on-escape = ["exit"]
        # Action to perform when the Enter key is pressed [possible values: save-to-clipboard, save-to-file]
        # Deprecated: use actions-on-enter instead
        action-on-enter = "save-to-clipboard"
        # Right click to copy
        # Deprecated: use actions-on-right-click instead
        right-click-copy = false
        # request no window decoration. Please note that the compositor has the final say in this. At this point. requires xdg-decoration-unstable-v1.
        no-window-decoration = true
        # experimental feature: adjust history size for brush input smooting (0: disabled, default: 0, try e.g. 5 or 10)
        brush-smooth-history-size = 10

        # Font to use for text annotations
        [font]
        family = "${config.stylix.fonts.sansSerif.name}"
        style = "Bold"

        # Custom colours for the colour palette
        [color-palette]
        # These will be shown in the toolbar for quick selection
        palette = [
            "#${colors.base0C}",
            "#${colors.base08}",
            "#${colors.base09}",
            "#${colors.base0D}",
            "#${colors.base0B}",
            "#${colors.base0E}",
        ]

        # These will be available in the color picker as presets
        # Leave empty to use GTK's default
        custom = [
            "#${colors.base0C}",
            "#${colors.base08}",
            "#${colors.base09}",
            "#${colors.base0A}",
            "#${colors.base0B}",
            "#${colors.base0E}",
            "#${colors.base0D}",
            "#${colors.base0F}",
        ]
      '';
    };
  };
}
