{
  user-settings,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.cli.kitty;
  inherit (config.lib.stylix) colors;
in
{

  options = {
    cli.kitty.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Kitty terminal.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Configure nautilus to use kitty when enabled
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "kitty";
    };

    ### HOME MANAGER SETTINGS
    home-manager.users."${user-settings.user.username}" = {

      programs.kitty = lib.mkMerge [
        {
          enable = true;
          # https://github.com/kovidgoyal/kitty-themes/tree/master/themes
          # themeFile is the name of the .conf file without the .conf
          package = pkgs.kitty;
          shellIntegration = {
            enableFishIntegration = true;
            enableZshIntegration = true;
            enableBashIntegration = true;
          };
          settings = {
            confirm_os_window_close = "0";
            hide_window_decorations = "yes";
            editor = "${pkgs.helix}/bin/hx";
            cursor_shape = "block";
            macos_titlebar_color = "background";
            
            # Clipboard settings
            clipboard_max_size = 0;
            copy_on_select = "clipboard";
            strip_trailing_spaces = "smart";
            
            # Window and appearance
            window_padding_width = 15;
            bold_font = "auto";
            italic_font = "auto";
            bold_italic_font = "auto";
            
            # Performance and behavior
            scrollback_lines = 10000;
            enable_audio_bell = "no";
            visual_bell_duration = 0;
            window_alert_on_bell = "yes";
            bell_on_tab = "yes";
            
            # Linux/Wayland optimizations
            linux_display_server = "auto";  # Auto-detect X11/Wayland
            wayland_titlebar_color = "background";
            
            # Window behavior for tiling WMs (Hyprland)
            remember_window_size = "no";
            initial_window_width = "80c";
            initial_window_height = "24c";
            resize_in_steps = "yes";
            
            # High-precision scrolling for Wayland
            touch_scroll_multiplier = 1.0;
            
            # Disable IME on Wayland for performance (if you don't need non-Latin input)
            wayland_enable_ime = "no";
            
            # Input method support for Linux
            text_composition_strategy = "platform";
            
            # Performance tuning (optimized for minimal latency)
            repaint_delay = 2;        # Reduced from default 10ms for faster repaints
            input_delay = 0;          # Zero input delay for immediate responsiveness
            sync_to_monitor = "no";   # Disable vsync for lower latency
            
            # Memory optimization
            scrollback_pager_history_size = 64;  # MB for scrollback pager
            
            # URL handling
            url_style = "curly";
            open_url_with = "default";
            detect_urls = "yes";

            # Stylix color integration
            foreground = lib.mkIf (config.stylix.enable or false) "#${colors.base05}";
            background = lib.mkIf (config.stylix.enable or false) "#${colors.base00}";
            selection_foreground = lib.mkIf (config.stylix.enable or false) "#${colors.base00}";
            selection_background = lib.mkIf (config.stylix.enable or false) "#${colors.base05}";
            cursor = lib.mkIf (config.stylix.enable or false) "#${colors.base05}";
            cursor_text_color = lib.mkIf (config.stylix.enable or false) "#${colors.base00}";

            # Terminal colors (base16)
            color0 = lib.mkIf (config.stylix.enable or false) "#${colors.base00}";
            color1 = lib.mkIf (config.stylix.enable or false) "#${colors.base08}";
            color2 = lib.mkIf (config.stylix.enable or false) "#${colors.base0B}";
            color3 = lib.mkIf (config.stylix.enable or false) "#${colors.base0A}";
            color4 = lib.mkIf (config.stylix.enable or false) "#${colors.base0D}";
            color5 = lib.mkIf (config.stylix.enable or false) "#${colors.base0E}";
            color6 = lib.mkIf (config.stylix.enable or false) "#${colors.base0C}";
            color7 = lib.mkIf (config.stylix.enable or false) "#${colors.base05}";
            color8 = lib.mkIf (config.stylix.enable or false) "#${colors.base03}";
            color9 = lib.mkIf (config.stylix.enable or false) "#${colors.base08}";
            color10 = lib.mkIf (config.stylix.enable or false) "#${colors.base0B}";
            color11 = lib.mkIf (config.stylix.enable or false) "#${colors.base0A}";
            color12 = lib.mkIf (config.stylix.enable or false) "#${colors.base0D}";
            color13 = lib.mkIf (config.stylix.enable or false) "#${colors.base0E}";
            color14 = lib.mkIf (config.stylix.enable or false) "#${colors.base0C}";
            color15 = lib.mkIf (config.stylix.enable or false) "#${colors.base07}";
          };
          
          # Key bindings for clipboard functionality
          keybindings = {
            "ctrl+shift+c" = "copy_to_clipboard";
            "ctrl+shift+v" = "paste_from_clipboard";
            "ctrl+shift+s" = "paste_from_selection";
            "shift+insert" = "paste_from_selection";
          };
          environment = {
            # Set the default shell to fish
            SHELL = "${pkgs.fish}/bin/fish";
            COLORTERM = "truecolor";
            WINIT_X11_SCALE_FACTOR = "1";
            EDITOR = "${pkgs.helix}/bin/hx";
          };
          font = {
            name = lib.mkForce "JetBrainsMono Nerd Font Mono";
            size = lib.mkForce 18;
          };
          
          # Explicitly specify font variants for better rendering
          settings = lib.mkMerge [
            (lib.mkAfter {
              # Use Medium weight for regular text (better readability than Regular)
              font_family = "JetBrainsMono NFM Medium";
              bold_font = "JetBrainsMono NFM SemiBold";
              italic_font = "JetBrainsMono NFM Medium Italic";
              bold_italic_font = "JetBrainsMono NFM SemiBold Italic";
              
              # Font features for better terminal experience
              font_features = "JetBrainsMonoNFM-Medium +zero +onum";
              
              # Fine-tune font rendering
              modify_font = "underline_position 2";
              modify_font = "underline_thickness 150%";
              
              # Disable problematic ligatures in terminal
              disable_ligatures = "cursor";
            })
          ];
        }
      ];
    };
  };
}
