{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  ...
}:
let
  cfg = config.cli.spotify;

  makeScriptPackages = pkgs.callPackage ../../../lib/make-script-packages { };

  spotifyScripts = makeScriptPackages {
    scriptsDir = ./scripts;
    scripts = [ "ncspot-save-playing" ];
    runtimeInputs = with pkgs; [
      netcat-gnu  # for nc command
      jq          # for JSON parsing
      libnotify   # for notify-send
    ];
  };

in
{
  options = {
    cli.spotify.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable spotify players.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      unstable.curl
      unstable.librespot
      unstable.spotify # official
      unstable.spotify-player
      # keep-sorted end
    ] ++ spotifyScripts.packages;

    # Add fish shell abbreviations if fish is enabled
    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable
      spotifyScripts.fishShellAbbrs;

    home-manager.users."${user-settings.user.username}" = {

      # NCSPOT
      programs.ncspot = {
        enable = true;
        package = pkgs.unstable.ncspot.override { withMPRIS = true; };
        settings = {
          shuffle = true;
          gapless = true;
          use_nerdfont = true;
          notify = true;

        };
      };

      # https://github.com/hrkfdn/ncspot/blob/main/doc/users.md#remote-control-ipc
      # running: echo 'save' | nc -W 1 -U $NCSPOT_SOCK
      #  will save the currently playing song to your library in NCSPOT
      home = {
        sessionVariables = {
          NCSPOT_SOCK = "/run/user/1000/ncspot/ncspot.sock";
        };

        # Custom ncspot desktop file with proper window class
        file = {
          ".local/share/applications/ncspot.desktop".text = ''
            [Desktop Entry]
            Name=ncspot
            Comment=ncurses Spotify client
            Exec=kitty --class=ncspot -e ncspot
            Terminal=false
            Type=Application
            Icon=spotify
            Categories=Audio;Music;Player;
            StartupWMClass=ncspot
          '';

          # spotify-player config (theming handled by stylix)
          ".config/spotify-player/app.toml".text = ''
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
    };
  };
}
