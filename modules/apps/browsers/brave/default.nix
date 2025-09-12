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

    home-manager.users."${user-settings.user.username}" = {
      programs.chromium = {
        enable = true;
        package = pkgs.unstable.brave;
        commandLineArgs = waylandFlags;
        extensions = [
          # pushover
          #"fcmngfmocgakhjghfmgbbhlkenccgpdh"
          # bookmark search
          #"cofpegcepiccpobikjoddpmmocficdjj"
          # kagi search
          # "cdglnehniifkbagbbombnjghhcihifij"
          # Just Read
          "dgmanlpmmkibanfdgjocnabmcaclkmod"
          # 1password
          "aeblfdkhhhdcdjpifhhbdiojplfjncoa"
          # dark reader
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
          # ublock origin (though Brave has built-in ad blocking)
          "cjpalhdlnbpafiamejdnhcphjbkeiagm"
          # tactiq
          #"fggkaccpbmombhnjkjokndojfgagejfb"
          # okta
          "glnpjglilkicbckjpbgcfkogebgllemb"
          # grammarly
          "kbfnbcaeplbcioakkpcpgfkobkghlhen"
          # simplify
          "pbmlfaiicoikhdbjagjbglnbfcbcojpj"
          # todoist
          "jldhpllghnbhlbpcmnajkpdmadaolakh"
          # Loom video recording
          # "liecbddmkiiihnedobmlmillhodjkdmb"
          # Privacy Badger
          #"pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
          # Checker Plus for Mail
          "oeopbcgkkoapgobdbedcemjljbihmemj"
          # Checker Plus for Cal
          "hkhggnncdpfibdhinjiegagmopldibha"
          # Google docs offline
          "ghbmnnjooekpmoecnnnilnnbdlolhkhi"
          # Markdown downloader
          "pcmpcfapbekmbjjkdalcgopdkipoggdi"
          # obsidian clipper
          #"mphkdfmipddgfobjhphabphmpdckgfhb"
          # URL/Tab Manager
          "egiemoacchfofdhhlfhkdcacgaopncmi"
          # Mail message URL
          "bcelhaineggdgbddincjkdmokbbdhgch"
          # Catppuccin Github icons
          #"lnjaiaapbakfhlbjenjkhffcdpoompki"
          # Glean browser extension
          # "cfpdompphcacgpjfbonkdokgjhgabpij" # overrides my speed dial extention
          # gnome extention plugin
          "gphhapmejobijbbhgpjhcjognlahblep"
          # copy to clipboard
          "miancenhdlkbmjmhlginhaaepbdnlllc"
          # Speed dial extention
          "jpfpebmajhhopeonhlcgidhclcccjcik"
          # Raindrop
          "ldgfbffkinooeloadekpmfoklnobpien"
          # email tracking for work
          #"pgbdljpkijehgoacbjpolaomhkoffhnl"
          # zoom
          #"kgjfgplpablkjnlkjmjdecgdpfankdle"
          # Floccus Bookmark Sync
          #"fnaicdffflnofjppbagibeoednhnbjhg"
          # Travel Arrow
          #"coplmfnphahpcknbchcehdikbdieognn"
          # xbrowsersync
          # "lcbjdhceifofjlpecfpeimnnphbcjgnc"
          # tineye
          # "haebnnbpedcbhciplfhjjkbafijpncjl"
          # Gainsight Assist
          # "kbiepllbcbandmpckhoejbgcaddcpbno"
          # Material Theme Dark (blue-grey)
          # "paoafodbgcjnmijjepmpgnlhnogaahme"
          # Material Theme Dark (black)
          # "bokiaeofleahagjcmcodjofilfdnoblk"
          # Adguard AdBlocker
          "bgnkhhnnamicmpeenaelnjfhikgbkllg"
          # Dracula theme
          # "gfapcejdoghpoidkfodoiiffaaibpaem"
        ];
      };

      # Create Wayland-optimized flags config files
      home.file = {
        ".config/brave-flags.conf".text = lib.concatStringsSep "\n" waylandFlags;
        ".config/electron-flags.conf".text = lib.concatStringsSep "\n" waylandFlags;
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

      # Override desktop file for proper Wayland execution
      xdg.desktopEntries.brave-browser = {
        name = "Brave Web Browser";
        genericName = "Web Browser";
        comment = "Access the Internet";
        exec = "brave ${lib.concatStringsSep " " waylandFlags} %U";
        startupNotify = true;
        terminal = false;
        icon = "brave-browser";
        type = "Application";
        categories = [ "Network" "WebBrowser" ];
        mimeType = [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/ftp"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
        ];
        actions = {
          new-window = {
            name = "New Window";
            exec = "brave ${lib.concatStringsSep " " waylandFlags} --new-window";
          };
          new-private-window = {
            name = "New Incognito Window";
            exec = "brave ${lib.concatStringsSep " " waylandFlags} --incognito";
          };
        };
      };

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