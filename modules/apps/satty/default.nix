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
        # Note: Removed deprecated and unsupported options
        # These were causing config errors with current satty version

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
