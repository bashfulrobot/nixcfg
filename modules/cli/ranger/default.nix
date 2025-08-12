{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.cli.ranger;
in
{
  options = {
    cli.ranger.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable ranger file manager.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${user-settings.user.username}" = {
      imports = [
        ./build/config.nix
        ./build/commands.nix
        ./build/rifle.nix
      ];

      programs.ranger = {
        enable = true;
        aliases = {
          e = "edit";
          q = "quit";
          qq = "quit!";
          qall = "quitall";
          setl = "setlocal";
          filter = "";
        };
      };

      # Dependencies for file previews and operations (ported from yazi)
      home.packages = with pkgs; [
        ffmpeg-full # for mediainfo
        glow # markdown preview
        libreoffice # office document preview
        mediainfo # media file info
        ouch # archive extraction
        unstable.poppler-utils # PDF handling
        ripdrag # drag and drop
        trash-cli # trash support
        udisks # mount support
        
        # Additional ranger-specific tools
        w3m # for image preview in terminal
        highlight # syntax highlighting
        atool # archive handling
        libcaca # image preview fallback
        lynx # web content
        elinks # web content alternative
        pandoc # document conversion
      ];

      # Shell integration function for ranger (similar to yazi's 'y' function)
      programs.fish.functions = {
        ranger-cd = ''
          set tempfile (mktemp -t "ranger-cd.XXXXXX")
          ranger --choosedir="$tempfile" $argv
          if test -f "$tempfile" 
            set rangerpwd (cat "$tempfile")
            if test -n "$rangerpwd" -a "$rangerpwd" != "$PWD"
              builtin cd -- "$rangerpwd"
            end
          end
          rm -f -- "$tempfile"
        '';
        
        # Alias for convenience
        r = "ranger-cd";
      };
    };
  };
}