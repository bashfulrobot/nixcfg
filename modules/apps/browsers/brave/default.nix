{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.browsers.brave;

  # Wayland-optimized command line arguments for Brave
  waylandFlags = [
    "--enable-features=UseOzonePlatform"
    "--ozone-platform=wayland"
    "--enable-features=WaylandWindowDecorations"
    "--ozone-platform-hint=auto"
    "--gtk-version=4"
    "--enable-features=VaapiVideoDecodeLinuxGL"
    "--enable-features=VaapiVideoEncoder"
    "--disable-features=UseChromeOSDirectVideoDecoder"
  ];
in
{
  options = {
    apps.browsers.brave = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Brave browser with Wayland optimizations.";
      };

      setAsDefault = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set Brave as the default browser";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Configure Zoom Flatpak to use this browser when set as default
    services.flatpak.overrides."us.zoom.Zoom".Environment.BROWSER = lib.mkIf cfg.setAsDefault "brave";

    # Install Brave browser
    environment.systemPackages = with pkgs; [ unstable.brave ];

    home-manager.users."${user-settings.user.username}" = {
      # Configure chromium extensions for Brave using home-manager
      programs.chromium = {
        enable = true;
        package = pkgs.unstable.brave;
        extensions = [
          # Just Read
          "dgmanlpmmkibanfdgjocnabmcaclkmod"
          # 1password
          "aeblfdkhhhdcdjpifhhbdiojplfjncoa"
          # dark reader
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
          # ublock origin
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"
          # okta
          "glnpjglilkicbckjpbgcfkogebgllemb"
          # grammarly
          "kbfnbcaeplbcioakkpcpgfkobkghlhen"
          # simplify
          "pbmlfaiicoikhdbjagjbglnbfcbcojpj"
          # todoist
          "jldhpllghnbhlbpcmnajkpdmadaolakh"
          # Checker Plus for Mail
          "oeopbcgkkoapgobdbedcemjljbihmemj"
          # Checker Plus for Cal
          "hkhggnncdpfibdhinjiegagmopldibha"
          # Google docs offline
          "ghbmnnjooekpmoecnnnilnnbdlolhkhi"
          # Markdown downloader
          "pcmpcfapbekmbjjkdalcgopdkipoggdi"
          # gnome extention plugin
          "gphhapmejobijbbhgpjhcjognlahblep"
          # copy to clipboard
          "miancenhdlkbmjmhlginhaaepbdnlllc"
          # Speed dial extention
          "jpfpebmajhhopeonhlcgidhclcccjcik"
          # Raindrop
          "ldgfbffkinooeloadekpmfoklnobpien"
          # Adguard AdBlocker
          "bgnkhhnnamicmpeenaelnjfhikgbkllg"
        ];
      };
      # Create Wayland-optimized flags config files
      xdg.configFile = {
        "brave-flags.conf".text = lib.concatStringsSep "\n" waylandFlags;
        "electron-flags.conf".text = lib.concatStringsSep "\n" waylandFlags;
      };

      home.sessionVariables = lib.mkMerge [
        {
          # Force Wayland for Electron apps
          ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        }
        (lib.mkIf cfg.setAsDefault {
          BROWSER = "brave";
        })
      ];

      xdg.mimeApps = lib.mkIf cfg.setAsDefault {
        enable = true;
        defaultApplications = {
          "text/html" = [ "brave-browser.desktop" ];
          "x-scheme-handler/http" = [ "brave-browser.desktop" ];
          "x-scheme-handler/https" = [ "brave-browser.desktop" ];
          "x-scheme-handler/about" = [ "brave-browser.desktop" ];
          "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
          "applications/x-www-browser" = [ "brave-browser.desktop" ];
        };
      };
    };
  };
}