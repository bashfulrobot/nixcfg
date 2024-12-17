{ user-settings, pkgs, secrets, config, lib, ... }:
let cfg = config.cli.spotify;

in {
  options = {
    cli.spotify.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable spotify players.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ spotify-player librespot ];

    home-manager.users."${user-settings.user.username}" = {

      # NCSPOT
      programs.ncspot = {
        enable = true;
        package = pkgs.ncspot.override { withMPRIS = true; };
        settings = {
          shuffle = true;
          gapless = true;
          use_nerdfont = true;
          notify = true;

          theme = {
            background = "#1f1f1f";
            primary = "#6f8396"; # Slate accent color
            secondary = "#a9a9a9"; # Dark gray secondary color
            title = "#6f8396"; # Slate accent color for title
            playing = "#1f1f1f"; # Slate accent color for playing
            playing_selected = "#6f8396"; # Light blue for selected playing
            playing_bg = "#ffffff"; # Light background for playing
            highlight = "#1f1f1f"; # Slate accent color for highlight
            highlight_bg = "#d3d3d3";
            error = "#e06c75";
            error_bg = "#d56199";
            statusbar = "#6f8396";
            statusbar_progress = "#2190a4"; # Dark blue for status bar progress
            statusbar_bg = "#ffffff"; # Light background for status bar
            cmdline = "#6f8396"; # Slate accent color for command line
            cmdline_bg = "#ffffff"; # Light background for command line
            search_match = "#c88800"; # Yellow for search match
          };

        };
      };

      home.sessionVariables = {
        NCSPOT_SOCK = "/run/user/1000/ncspot/ncspot.sock";
      };

      # spotify-player
      home.file.".config/spotify-player/themes.toml".text = ''

        [[themes]]
          name = "adwaita_slate"
          [themes.palette]
          background = "#ffffff"  # Adwaita light background
          foreground = "#000000"  # Adwaita light foreground
          black = "#2e3436"       # Adwaita black
          red = "#cc0000"         # Adwaita red
          green = "#4e9a06"       # Adwaita green
          yellow = "#c4a000"      # Adwaita yellow
          blue = "#3465a4"        # Adwaita blue
          magenta = "#75507b"     # Adwaita magenta
          cyan = "#06989a"        # Adwaita cyan
          white = "#d3d7cf"       # Adwaita white
          bright_black = "#555753" # Adwaita bright black
          bright_red = "#ef2929"   # Adwaita bright red
          bright_green = "#8ae234" # Adwaita bright green
          bright_yellow = "#fce94f" # Adwaita bright yellow
          bright_blue = "#729fcf"  # Adwaita bright blue
          bright_magenta = "#ad7fa8" # Adwaita bright magenta
          bright_cyan = "#34e2e2"  # Adwaita bright cyan
          bright_white = "#eeeeec"  # Adwaita bright white
          accent = "#6f8396"       # Slate accent color

          # a theme based on the application's `default` theme
          [[themes]]
          name = "default2"
          [themes.palette]
          # default theme doesn't have `foreground` and `background` specified
          black = "black"
          red = "red"
          green = "green"
          yellow = "yellow"
          blue = "blue"
          magenta = "magenta"
          cyan = "cyan"
          white = "white"
          bright_black = "bright_black"
          bright_red = "bright_red"
          bright_green = "bright_green"
          bright_yellow = "bright_yellow"
          bright_blue = "bright_blue"
          bright_magenta = "bright_magenta"
          bright_cyan = "bright_cyan"
          bright_white = "bright_white"
          [themes.component_style]
          block_title = { fg = "Magenta"  }
          border = {}
          playback_track = { fg = "Cyan", modifiers = ["Bold"] }
          playback_artists = { fg = "Cyan", modifiers = ["Bold"] }
          playback_album = { fg = "Yellow" }
          playback_metadata = { fg = "BrightBlack" }
          playback_progress_bar = { bg = "BrightBlack", fg = "Green" }
          current_playing = { fg = "Green", modifiers = ["Bold"] }
          page_desc = { fg = "Cyan", modifiers = ["Bold"] }
          table_header = { fg = "Blue" }
          selection = { modifiers = ["Bold", "Reversed"] }

               [[themes]]
          name = "nord"
          [themes.palette]
          background = "#2E3440"
          foreground = "#D8DEE9"
          black = "#3B4252"
          red = "#BF616A"
          green = "#A3BE8C"
          yellow = "#EBCB8B"
          blue = "#81A1C1"
          magenta = "#B48EAD"
          cyan = "#88C0D0"
          white = "#E5E9F0"
          bright_black = "#4C566A"
          bright_red = "#BF616A"
          bright_green = "#A3BE8C"
          bright_yellow = "#EBCB8B"
          bright_blue = "#81A1C1"
          bright_magenta = "#B48EAD"
          bright_cyan = "#8FBCBB"
          bright_white = "#ECEFF4"

          [[themes]]
          name = "dracula"
          [themes.palette]
          background = "#1e1f29"
          foreground = "#f8f8f2"
          black = "#000000"
          red = "#ff5555"
          green = "#50fa7b"
          yellow = "#f1fa8c"
          blue = "#bd93f9"
          magenta = "#ff79c6"
          cyan = "#8be9fd"
          white = "#bbbbbb"
          bright_black = "#555555"
          bright_red = "#ff5555"
          bright_green = "#50fa7b"
          bright_yellow = "#f1fa8c"
          bright_blue = "#bd93f9"
          bright_magenta = "#ff79c6"
          bright_cyan = "#8be9fd"
          bright_white = "#ffffff"

          [[themes]]
          name = "gruvbox_dark"
          [themes.palette]
          background = "#282828"
          foreground = "#ebdbb2"
          black = "#282828"
          red = "#cc241d"
          green = "#98971a"
          yellow = "#d79921"
          blue = "#458588"
          magenta = "#b16286"
          cyan = "#689d6a"
          white = "#a89984"
          bright_black = "#928374"
          bright_red = "#fb4934"
          bright_green = "#b8bb26"
          bright_yellow = "#fabd2f"
          bright_blue = "#83a598"
          bright_magenta = "#d3869b"
          bright_cyan = "#8ec07c"
          bright_white = "#ebdbb2"
          [[themes]]
          name = "gruvbox_light"
          [themes.palette]
          background = "#fbf1c7"
          foreground = "#282828"
          black = "#fbf1c7"
          red = "#9d0006"
          green = "#79740e"
          yellow = "#b57614"
          blue = "#076678"
          magenta = "#8f3f71"
          cyan = "#427b58"
          white = "#3c3836"
          bright_black = "#9d8374"
          bright_red = "#cc241d"
          bright_green = "#98971a"
          bright_yellow = "#d79921"
          bright_blue = "#458588"
          bright_magenta = "#b16186"
          bright_cyan = "#689d69"
          bright_white = "#7c6f64"

          [[themes]]
          name = "solarized_dark"
          [themes.palette]
          background = "#002b36"
          foreground = "#839496"
          black = "#073642"
          red = "#dc322f"
          green = "#859900"
          yellow = "#b58900"
          blue = "#268bd2"
          magenta = "#d33682"
          cyan = "#2aa198"
          white = "#eee8d5"
          bright_black = "#002b36"
          bright_red = "#cb4b16"
          bright_green = "#586e75"
          bright_yellow = "#657b83"
          bright_blue = "#839496"
          bright_magenta = "#6c71c4"
          bright_cyan = "#93a1a1"
          bright_white = "#fdf6e3"

          [[themes]]
          name = "solarized_light"
          [themes.palette]
          background = "#fdf6e3"
          foreground = "#657b83"
          black = "#073642"
          red = "#dc322f"
          green = "#859900"
          yellow = "#b58900"
          blue = "#268bd2"
          magenta = "#d33682"
          cyan = "#2aa198"
          white = "#eee8d5"
          bright_black = "#002b36"
          bright_red = "#cb4b16"
          bright_green = "#586e75"
          bright_yellow = "#657b83"
          bright_blue = "#839496"
          bright_magenta = "#6c71c4"
          bright_cyan = "#93a1a1"
          bright_white = "#fdf6e3"

          [[themes]]
          name = "tokyonight"
          [themes.palette]
          background = "#1f2335"
          foreground = "#c0caf5"
          black = "#414868"
          red = "#f7768e"
          green = "#9ece6a"
          yellow = "#e0af68"
          blue = "#2ac3de"
          magenta = "#bb9af7"
          cyan = "#7dcfff"
          white = "#eee8d5"
          bright_black = "#24283b"
          bright_red = "#ff4499"
          bright_green = "#73daca"
          bright_yellow = "#657b83"
          bright_blue = "#839496"
          bright_magenta = "#ff007c"
          bright_cyan = "#93a1a1"
          bright_white = "#fdf6e3"

      '';

      home.file.".config/spotify-player/app.toml".text = ''
        theme = "adwaita_slate"
        client_id = "${secrets.spotify-player.client-id}"
        client_port = 8080
        playback_format = """
        {track} • {artists}
        {album}
        {metadata}"""
        tracks_playback_limit = 50
        app_refresh_duration_in_ms = 32
        playback_refresh_duration_in_ms = 0
        page_size_in_rows = 20
        play_icon = "▶"
        pause_icon = "▌▌"
        liked_icon = "♥"
        border_type = "Plain"
        progress_bar_type = "Rectangle"
        playback_window_position = "Top"
        cover_img_length = 9
        cover_img_width = 5
        cover_img_scale = 1.0
        playback_window_width = 6
        enable_media_control = true
        enable_streaming = "Always"
        enable_notify = true
        enable_cover_image_cache = true
        default_device = "spotify-player"
        notify_streaming_only = false

        [copy_command]
        command = "xclip"
        args = [
            "-sel",
            "c",
        ]

        [notify_format]
        summary = "{track} • {artists}"
        body = "{album}"

        [device]
        name = "spotify-player"
        device_type = "speaker"
        volume = 70
        bitrate = 320
        audio_cache = false
        normalization = false

      '';
    };
  };
}
