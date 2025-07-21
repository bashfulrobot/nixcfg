# Options: https://search.nixos.org/options?channel=unstable&show=programs.chromium.extraOpts&from=0&size=50&sort=relevance&type=packages&query=programs.chromium
{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.chrome-based-browser;

  defaultApplication = "chromium";

  chromiumIcon = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/2/28/Chromium_Logo.svg";
    sha256 = "sha256-vLAX3+o5ENErSPsabpUNK1JHYw8A9KPo5TaB+OdQRt4="; # Replace with actual hash
  };

  chromiumDesktopItem = pkgs.makeDesktopItem {
    name = "chromium";
    desktopName = "Chromium";
    genericName = "Chromium Web Browser";
    comment = "Access the Internet";
    exec = "${pkgs.chromium}/bin/chromium %U";
    startupWMClass = "chromium-browser";
    startupNotify = true;
    terminal = false;
    icon = chromiumIcon;
    type = "Application";
    categories = [
      "Network"
      "WebBrowser"
    ];
  };

  chromiumPackage = pkgs.stdenv.mkDerivation {
    name = "chromium-package";
    srcs = [ chromiumDesktopItem ];
    installPhase = ''
      mkdir -p $out/share/applications
      cp ${chromiumDesktopItem}/share/applications/chromium.desktop $out/share/applications/chromium.desktop
      mkdir -p $out/share/icons/hicolor/scalable/apps
      cp ${chromiumIcon} $out/share/icons/hicolor/scalable/apps/chromium.svg
    '';
  };

in
{

  options = {
    apps.chrome-based-browser = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable a chromium based browser.";
      };
    };

  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      # chromiumPackage
      (chromium.override { enableWideVine = true; })
    ];

    programs.chromium = {
      enable = true;
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
        # ublock origin
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
        "liecbddmkiiihnedobmlmillhodjkdmb"
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
        "kbiepllbcbandmpckhoejbgcaddcpbno"
        # Material Theme Dark (blue-grey)
        # "paoafodbgcjnmijjepmpgnlhnogaahme"
        # Material Theme Dark (black)
        "bokiaeofleahagjcmcodjofilfdnoblk"
        # Adguard AdBlocker
        "bgnkhhnnamicmpeenaelnjfhikgbkllg"
        # Dracula theme
        "gfapcejdoghpoidkfodoiiffaaibpaem"

      ];
      # initialPrefs = {
      #   "https_only_mode_auto_enabled" = true;
      #   "privacy_guide" = { "viewed" = true; };
      #   "safebrowsing" = {
      #     "enabled" = false;
      #     "enhanced" = false;
      #   };
      #   "autofill" = {
      #     "credit_card_enabled" = false;
      #     # "profile_enabled" = false;
      #   };
      #   "search" = { "suggest_enabled" = false; };
      #   "browser" = {
      #     "clear_data" = {
      #       "cache" = false;
      #       "browsing_data" = false;
      #       "cookies" = false;
      #       "cookies_basic" = false;
      #       "download_history" = true;
      #       "form_data" = true;
      #       "time_period" = 4;
      #       "time_period_basic" = 4;
      #     };
      #     "has_seen_welcome_page" = true;
      #     "theme" = { "follows_system_colors" = true; };
      #   };
      #   "enable_do_not_track" = true;
      #   "https_only_mode_enabled" = true;
      #   "intl"."selected_languages" = "en-CA,en-US";
      #   "payments"."can_make_payment_enabled" = false;
      # };
      # extraOpts = {
      #   "BrowserSignin" = 0;
      #   "SyncDisabled" = true;
      #   "PasswordManagerEnabled" = false;
      #   "SpellcheckEnabled" = true;
      #   "SpellcheckLanguage" = [ "en-CA" "en-US" ];

      #   "CloudReportingEnabled" = false;
      #   "SafeBrowsingEnabled" = false;
      #   "ReportSafeBrowsingData" = false;
      #   "AllowDinosaurEasterEgg" = false; # : (
      #   "AllowOutdatedPlugins" = true;
      #   "DefaultBrowserSettingEnabled" = false;
      #   "PromotionalTabsEnabled" = false;
      #   "MetricsReportingEnabled" = false;
      #   "PaymentMethodQueryEnabled" = false;
      #   "ShoppingListEnabled" = false;

      #   "AlwaysOpenPdfExternally" = true;
      #   "ShowHomeButton" = false;

      #   "AutofillAddressEnabled" = false;
      #   "AutofillCreditCardEnabled" = false;

      #   # voice assistant
      #   # "VoiceInteractionContextEnabled" = false;
      #   # "VoiceInteractionHotwordEnabled" = false;
      #   # "VoiceInteractionQuickAnswersEnabled" = false;
      # };
      # "defaultSearchProviderEnabled" = true;
      # "defaultSearchProviderSearchURL" =
      #   "https://kagi.com/search?q={searchTerms}";
      # "defaultSearchProviderSuggestURL" =
      #   "https://kagi.com/api/autosuggest?q={searchTerms}";
    };

    home-manager.users."${user-settings.user.username}" = {

      home.sessionVariables.BROWSER = "${defaultApplication}";


      # xdg.mimeApps.defaultApplications = {
      #   "text/html" = "${defaultApplication}.desktop";
      #   "x-scheme-handler/http" = "${defaultApplication}.desktop";
      #   "x-scheme-handler/https" = "${defaultApplication}.desktop";
      #   "x-scheme-handler/about" = "${defaultApplication}.desktop";
      #   "x-scheme-handler/unknown" = "${defaultApplication}.desktop";
      # };

      # force chromium to use wayland - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer
      # home.file.".config/chromium-flags.conf".text = ''
      #   --enable-features=UseOzonePlatform
      #   --ozone-platform=wayland
      #   --enable-features=WaylandWindowDecorations
      #   --ozone-platform-hint=auto
      #   --gtk-version=4
      # '';
      #  --force-device-scale-factor=1

      home.file =
        let
          flags = ''
            --enable-features=UseOzonePlatform
            --ozone-platform=wayland
            --enable-features=WaylandWindowDecorations
            --ozone-platform-hint=auto
            --gtk-version=4
          '';
        in
        {
          ".config/chromium-flags.conf".text = flags;
          ".config/electron-flags.conf".text = flags;
          ".config/electron-flags16.conf".text = flags;
          ".config/electron-flags17.conf".text = flags;
          ".config/electron-flags18.conf".text = flags;
          ".config/electron-flags19.conf".text = flags;
          ".config/electron-flags20.conf".text = flags;
          ".config/electron-flags21.conf".text = flags;
          ".config/electron-flags22.conf".text = flags;
          ".config/electron-flags23.conf".text = flags;
          ".config/electron-flags24.conf".text = flags;
          ".config/electron-flags25.conf".text = flags;
          # Dark Reader configuration using stylix theme colors
          ".config/darkreader/Dark-Reader-Settings.json".text = 
            let
              # Access stylix colors when available
              inherit (config.lib.stylix.colors) base00 base05 base01 base0D base07 base02;
              
              # Fallback colors if stylix is not configured
              backgroundColor = if config.stylix.enable then "#${base00}" else "#1e1e2e";
              textColor = if config.stylix.enable then "#${base05}" else "#cdd6f4";
              surfaceColor = if config.stylix.enable then "#${base01}" else "#313244";
              accentColor = if config.stylix.enable then "#${base0D}" else "#89b4fa";
              lightBackgroundColor = if config.stylix.enable then "#${base07}" else "#eff1f5";
              lightTextColor = if config.stylix.enable then "#${base02}" else "#4c4f69";
            in
            builtins.toJSON {
              schemeVersion = 2;
              enabled = true;
              fetchNews = true;
              theme = {
                mode = 1; # Dark mode
                brightness = 100;
                contrast = 100;
                grayscale = 0;
                sepia = 0;
                useFont = false;
                fontFamily = if config.stylix.enable then config.stylix.fonts.monospace.name else "JetBrainsMono Nerd Font";
                textStroke = 0;
                engine = "dynamicTheme";
                stylesheet = "";
                darkSchemeBackgroundColor = backgroundColor;
                darkSchemeTextColor = textColor;
                lightSchemeBackgroundColor = lightBackgroundColor;
                lightSchemeTextColor = lightTextColor;
                scrollbarColor = surfaceColor;
                selectionColor = accentColor;
                styleSystemControls = true;
                lightColorScheme = "Default";
                darkColorScheme = "Default";
                immediateModify = false;
              };
              presets = [];
              customThemes = [
                {
                  builtIn = true;
                  theme = {
                    mode = 1;
                    brightness = 100;
                    contrast = 100;
                    grayscale = 0;
                    sepia = 0;
                    useFont = false;
                    fontFamily = if config.stylix.enable then config.stylix.fonts.monospace.name else "JetBrainsMono Nerd Font";
                    textStroke = 0;
                    engine = "cssFilter";
                    stylesheet = "";
                    darkSchemeBackgroundColor = backgroundColor;
                    darkSchemeTextColor = textColor;
                    lightSchemeBackgroundColor = lightBackgroundColor;
                    lightSchemeTextColor = lightTextColor;
                    scrollbarColor = surfaceColor;
                    selectionColor = accentColor;
                    styleSystemControls = true;
                    lightColorScheme = "Default";
                    darkColorScheme = "Default";
                    immediateModify = false;
                  };
                  url = [ "*.officeapps.live.com" ];
                }
                {
                  builtIn = true;
                  theme = {
                    mode = 1;
                    brightness = 100;
                    contrast = 100;
                    grayscale = 0;
                    sepia = 0;
                    useFont = false;
                    fontFamily = if config.stylix.enable then config.stylix.fonts.monospace.name else "JetBrainsMono Nerd Font";
                    textStroke = 0;
                    engine = "cssFilter";
                    stylesheet = "";
                    darkSchemeBackgroundColor = backgroundColor;
                    darkSchemeTextColor = textColor;
                    lightSchemeBackgroundColor = lightBackgroundColor;
                    lightSchemeTextColor = lightTextColor;
                    scrollbarColor = surfaceColor;
                    selectionColor = accentColor;
                    styleSystemControls = true;
                    lightColorScheme = "Default";
                    darkColorScheme = "Default";
                    immediateModify = false;
                  };
                  url = [ "*.sharepoint.com" ];
                }
                {
                  builtIn = true;
                  theme = {
                    mode = 1;
                    brightness = 100;
                    contrast = 100;
                    grayscale = 0;
                    sepia = 0;
                    useFont = false;
                    fontFamily = if config.stylix.enable then config.stylix.fonts.monospace.name else "JetBrainsMono Nerd Font";
                    textStroke = 0;
                    engine = "cssFilter";
                    stylesheet = "";
                    darkSchemeBackgroundColor = backgroundColor;
                    darkSchemeTextColor = textColor;
                    lightSchemeBackgroundColor = lightBackgroundColor;
                    lightSchemeTextColor = lightTextColor;
                    scrollbarColor = surfaceColor;
                    selectionColor = accentColor;
                    styleSystemControls = true;
                    lightColorScheme = "Default";
                    darkColorScheme = "Default";
                    immediateModify = false;
                  };
                  url = [ "docs.google.com" ];
                }
                {
                  builtIn = true;
                  theme = {
                    mode = 1;
                    brightness = 100;
                    contrast = 100;
                    grayscale = 0;
                    sepia = 0;
                    useFont = false;
                    fontFamily = if config.stylix.enable then config.stylix.fonts.monospace.name else "JetBrainsMono Nerd Font";
                    textStroke = 0;
                    engine = "cssFilter";
                    stylesheet = "";
                    darkSchemeBackgroundColor = backgroundColor;
                    darkSchemeTextColor = textColor;
                    lightSchemeBackgroundColor = lightBackgroundColor;
                    lightSchemeTextColor = lightTextColor;
                    scrollbarColor = surfaceColor;
                    selectionColor = accentColor;
                    styleSystemControls = true;
                    lightColorScheme = "Default";
                    darkColorScheme = "Default";
                    immediateModify = false;
                  };
                  url = [ "onedrive.live.com" ];
                }
              ];
              enabledByDefault = true;
              enabledFor = [];
              disabledFor = [
                "mail.google.com"
                "docs.google.com"
                "www.linkedin.com"
              ];
              changeBrowserTheme = false;
              syncSettings = true;
              syncSitesFixes = false;
              automation = {
                behavior = "OnOff";
                enabled = false;
                mode = "";
              };
              time = {
                activation = "18:00";
                deactivation = "9:00";
              };
              location = {
                latitude = null;
                longitude = null;
              };
              previewNewDesign = false;
              previewNewestDesign = false;
              enableForPDF = true;
              enableForProtectedPages = false;
              enableContextMenus = false;
              detectDarkTheme = true;
              displayedNews = [ "google-docs-bugs" ];
              installation = {
                date = 1749434934401;
                reason = "install";
                version = "4.9.106";
              };
            };
        };
    };
  };
}
