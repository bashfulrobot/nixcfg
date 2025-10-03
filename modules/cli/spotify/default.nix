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

  ncspot-save-playing = pkgs.writeShellApplication {
    name = "ncspot-save-playing";

    # runtimeInputs = [ pkgs.restic pkgs.pass ];

    text = ''
      #!/run/current-system/sw/bin/env bash

      echo "save" | nc -W 1 -U /run/user/1000/ncspot/ncspot.sock
      response=$(nc -W 1 -U /run/user/1000/ncspot/ncspot.sock)
      title=$(echo "$response" | jq -r '.playable.title')
      artist=$(echo "$response" | jq -r '.playable.artists[0]')
      cover_url=$(echo "$response" | jq -r '.playable.cover_url')

      # Download the album art
      cover_path="/tmp/album_cover.jpg"
      curl -s -o "$cover_path" "$cover_url"

      # Send notification with album art
      notify-send --app-name="NCSPOT" -i "$cover_path" "Song Saved" "$title - $artist"

      exit 0
    '';
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
      unstable.spotify-player
      unstable.librespot
      ncspot-save-playing
      unstable.curl
      unstable.spotify # official
    ];

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

        # spotify-player config (theming handled by stylix)
        file = {
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

        # Hide ncspot from desktop menus
        file.".local/share/applications/ncspot.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
      };
    };
  };
}
