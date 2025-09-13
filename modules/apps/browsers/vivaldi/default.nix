{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.browsers.vivaldi;
  inherit (config.lib.stylix) colors;
in
{

  options = {
    apps.browsers.vivaldi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable vivaldi browser.";
      };

      setAsDefault = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set Vivaldi as the default browser";
      };
    };

  };

  config = lib.mkIf cfg.enable {
    # Configure Zoom Flatpak to use this browser when set as default
    services.flatpak.overrides."us.zoom.Zoom".Environment.BROWSER = lib.mkIf cfg.setAsDefault "vivaldi";

    environment.systemPackages = with pkgs; [
      (unstable.vivaldi.override {
        proprietaryCodecs = true;
        inherit (unstable) vivaldi-ffmpeg-codecs;
        enableWidevine = true; # Seen some reports that can cause a crash
        commandLineArgs = [
          "--ozone-platform=wayland"
          "--ozone-platform-hint=auto"
          "--enable-features=WaylandWindowDecorations,AllowCSSModification"
        ];
      })
    ];

    # programs.chromium = {
    #   enable = true;
    #   extensions = [
    # pushover
    #"fcmngfmocgakhjghfmgbbhlkenccgpdh"
    # bookmark search
    #"cofpegcepiccpobikjoddpmmocficdjj"
    # kagi search
    # "cdglnehniifkbagbbombnjghhcihifij"
    # 1password
    # "aeblfdkhhhdcdjpifhhbdiojplfjncoa"
    # dark reader
    # "eimadpbcbfnmbkopoojfekhnkhdbieeh"
    # ublock origin
    # "cjpalhdlnbpafiamejdnhcphjbkeiagm"
    # tactiq
    #"fggkaccpbmombhnjkjokndojfgagejfb"
    # okta
    # "glnpjglilkicbckjpbgcfkogebgllemb"
    # grammarly
    # "kbfnbcaeplbcioakkpcpgfkobkghlhen"
    # simplify
    # "pbmlfaiicoikhdbjagjbglnbfcbcojpj"
    # todoist
    # "jldhpllghnbhlbpcmnajkpdmadaolakh"
    # Loom video recording
    # "liecbddmkiiihnedobmlmillhodjkdmb"
    # Privacy Badger
    #"pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
    # Checker Plus for Mail
    # "oeopbcgkkoapgobdbedcemjljbihmemj"
    # Checker Plus for Cal
    # "hkhggnncdpfibdhinjiegagmopldibha"
    # Google docs offline
    # "ghbmnnjooekpmoecnnnilnnbdlolhkhi"
    # Markdown downloader
    # "pcmpcfapbekmbjjkdalcgopdkipoggdi"
    # obsidian clipper
    #"mphkdfmipddgfobjhphabphmpdckgfhb"
    # URL/Tab Manager
    # "egiemoacchfofdhhlfhkdcacgaopncmi"
    # Mail message URL
    # "bcelhaineggdgbddincjkdmokbbdhgch"
    # Glean browser extension
    # "cfpdompphcacgpjfbonkdokgjhgabpij" # overrides my speed dial extention
    # gnome extention plugin
    # "gphhapmejobijbbhgpjhcjognlahblep"
    # copy to clipboard
    # "miancenhdlkbmjmhlginhaaepbdnlllc"
    # Speed dial extention
    # "jpfpebmajhhopeonhlcgidhclcccjcik"
    # Raindrop
    # "ldgfbffkinooeloadekpmfoklnobpien"
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
    # Perplexity AI
    #"bnaffjbjpgiagpondjlnneblepbdchol"
    # tineye
    # "haebnnbpedcbhciplfhjjkbafijpncjl"
    # Gainsight Assist
    # "kbiepllbcbandmpckhoejbgcaddcpbno"

    # ];
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
    # };

    home-manager.users."${user-settings.user.username}" = {

      home.sessionVariables = lib.mkIf cfg.setAsDefault {
        BROWSER = "vivaldi";
      };

      xdg.mimeApps = lib.mkIf cfg.setAsDefault {
        enable = true;
        defaultApplications = {
          "text/html" = [ "vivaldi-stable.desktop" ];
          "x-scheme-handler/http" = [ "vivaldi-stable.desktop" ];
          "x-scheme-handler/https" = [ "vivaldi-stable.desktop" ];
          "x-scheme-handler/about" = [ "vivaldi-stable.desktop" ];
          "x-scheme-handler/unknown" = [ "vivaldi-stable.desktop" ];
          "applications/x-www-browser" = [ "vivaldi-stable.desktop" ];
        };
      };

      # Generate Vivaldi theme settings.json files with Stylix colors
      home.file = lib.mkIf (config.stylix.enable or false) {
        "dev/nix/nixcfg/extras/helpers/vivaldi-theme/generated/stylix-dark-settings.json" = {
          text = builtins.toJSON {
            accentFromPage = false;
            accentOnWindow = true;
            accentSaturationLimit = 1;
            alpha = 1;
            backgroundImage = "";
            backgroundPosition = "stretch";
            blur = 0;
            buttons = {
              Back = "Back.svg";
              BreakMode = "BreakMode.svg";
              CalendarStatus = "CalendarStatus.svg";
              CaptureImages = "CaptureImages.svg";
              Clock = "Clock.svg";
              DownloadButton = "DownloadButton.svg";
              Extensions = "Extensions.svg";
              FastForward = "FastForward.svg";
              Forward = "Forward.svg";
              Home = "Home.svg";
              ImagesToggle = "ImagesToggle.svg";
              MailBack = "MailBack.svg";
              MailCompose = "MailCompose.svg";
              MailForward = "MailForward.svg";
              MailMsgArchive = "MailMsgArchive.svg";
              MailMsgArchiveRestore = "MailMsgArchiveRestore.svg";
              MailMsgAttach = "MailMsgAttach.svg";
              MailMsgDiscard = "MailMsgDiscard.svg";
              MailMsgEdit = "MailMsgEdit.svg";
              MailMsgFlag = "MailMsgFlag.svg";
              MailMsgForward = "MailMsgForward.svg";
              MailMsgLabel = "MailMsgLabel.svg";
              MailMsgMove = "MailMsgMove.svg";
              MailMsgReply = "MailMsgReply.svg";
              MailMsgReplyToAll = "MailMsgReplyToAll.svg";
              MailMsgSend = "MailMsgSend.svg";
              MailMsgShowHeaders = "MailMsgShowHeaders.svg";
              MailMsgSpam = "MailMsgSpam.svg";
              MailMsgSpamRestore = "MailMsgSpamRestore.svg";
              MailMsgStatusRead = "MailMsgStatusRead.svg";
              MailMsgStatusUnread = "MailMsgStatusUnread.svg";
              MailMsgTrash = "MailMsgTrash.svg";
              MailMsgTrashRestore = "MailMsgTrashRestore.svg";
              MailReload = "MailReload.svg";
              MailRenderingMethod = "MailRenderingMethod.svg";
              MailRenderingMethodText = "MailRenderingMethodText.svg";
              MailStatus = "MailStatus.svg";
              MailViewLayout = "MailViewLayout.svg";
              MailViewThreading = "MailViewThreading.svg";
              PageActions = "PageActions.svg";
              PanelBookmarks = "PanelBookmarks.svg";
              PanelCalendar = "PanelCalendar.svg";
              PanelContacts = "PanelContacts.svg";
              PanelDownloads = "PanelDownloads.svg";
              PanelFeeds = "PanelFeeds.svg";
              PanelHistory = "PanelHistory.svg";
              PanelMail = "PanelMail.svg";
              PanelNotes = "PanelNotes.svg";
              PanelReadingList = "PanelReadingList.svg";
              PanelSession = "PanelSession.svg";
              PanelTasks = "PanelTasks.svg";
              PanelToggle = "PanelToggle.svg";
              PanelTranslate = "PanelTranslate.svg";
              PanelWeb = "PanelWeb.svg";
              PanelWindow = "PanelWindow.svg";
              Proxy = "Proxy.svg";
              ReadingList = "ReadingList.svg";
              Reload = "Reload.svg";
              Rewind = "Rewind.svg";
              SearchField = "SearchField.svg";
              Settings = "Settings.svg";
              Stop = "Stop.svg";
              SyncStatus = "SyncStatus.svg";
              SyncedTabs = "SyncedTabs.svg";
              TabsTrash = "TabsTrash.svg";
              TilingToggle = "TilingToggle.svg";
              UpdateButton = "UpdateButton.svg";
              WorkspaceButton = "WorkspaceButton.svg";
            };
            colorAccentBg = "#${colors.base02}";
            colorBg = "#${colors.base00}";
            colorFg = "#${colors.base05}";
            colorHighlightBg = "#${colors.base0D}";
            colorWindowBg = "#${colors.base01}";
            contrast = 0;
            dimBlurred = false;
            engineVersion = 1;
            id = "e0f07456-2784-463f-9bd7-1ba84e1da52d";
            name = "Stylix Dark";
            preferSystemAccent = false;
            radius = 6;
            simpleScrollbar = false;
            transparencyTabBar = false;
            transparencyTabs = false;
            url = "";
            version = 1;
          };
        };

        "dev/nix/nixcfg/extras/helpers/vivaldi-theme/generated/stylix-light-settings.json" = {
          text = builtins.toJSON {
            accentFromPage = false;
            accentOnWindow = true;
            accentSaturationLimit = 1;
            alpha = 1;
            backgroundImage = "";
            backgroundPosition = "stretch";
            blur = 0;
            buttons = {
              Back = "Back.svg";
              BreakMode = "BreakMode.svg";
              CalendarStatus = "CalendarStatus.svg";
              CaptureImages = "CaptureImages.svg";
              Clock = "Clock.svg";
              DownloadButton = "DownloadButton.svg";
              Extensions = "Extensions.svg";
              FastForward = "FastForward.svg";
              Forward = "Forward.svg";
              Home = "Home.svg";
              ImagesToggle = "ImagesToggle.svg";
              MailBack = "MailBack.svg";
              MailCompose = "MailCompose.svg";
              MailForward = "MailForward.svg";
              MailMsgArchive = "MailMsgArchive.svg";
              MailMsgArchiveRestore = "MailMsgArchiveRestore.svg";
              MailMsgAttach = "MailMsgAttach.svg";
              MailMsgDiscard = "MailMsgDiscard.svg";
              MailMsgEdit = "MailMsgEdit.svg";
              MailMsgFlag = "MailMsgFlag.svg";
              MailMsgForward = "MailMsgForward.svg";
              MailMsgLabel = "MailMsgLabel.svg";
              MailMsgMove = "MailMsgMove.svg";
              MailMsgReply = "MailMsgReply.svg";
              MailMsgReplyToAll = "MailMsgReplyToAll.svg";
              MailMsgSend = "MailMsgSend.svg";
              MailMsgShowHeaders = "MailMsgShowHeaders.svg";
              MailMsgSpam = "MailMsgSpam.svg";
              MailMsgSpamRestore = "MailMsgSpamRestore.svg";
              MailMsgStatusRead = "MailMsgStatusRead.svg";
              MailMsgStatusUnread = "MailMsgStatusUnread.svg";
              MailMsgTrash = "MailMsgTrash.svg";
              MailMsgTrashRestore = "MailMsgTrashRestore.svg";
              MailReload = "MailReload.svg";
              MailRenderingMethod = "MailRenderingMethod.svg";
              MailRenderingMethodText = "MailRenderingMethodText.svg";
              MailStatus = "MailStatus.svg";
              MailViewLayout = "MailViewLayout.svg";
              MailViewThreading = "MailViewThreading.svg";
              PageActions = "PageActions.svg";
              PanelBookmarks = "PanelBookmarks.svg";
              PanelCalendar = "PanelCalendar.svg";
              PanelContacts = "PanelContacts.svg";
              PanelDownloads = "PanelDownloads.svg";
              PanelFeeds = "PanelFeeds.svg";
              PanelHistory = "PanelHistory.svg";
              PanelMail = "PanelMail.svg";
              PanelNotes = "PanelNotes.svg";
              PanelReadingList = "PanelReadingList.svg";
              PanelSession = "PanelSession.svg";
              PanelTasks = "PanelTasks.svg";
              PanelToggle = "PanelToggle.svg";
              PanelTranslate = "PanelTranslate.svg";
              PanelWeb = "PanelWeb.svg";
              PanelWindow = "PanelWindow.svg";
              Proxy = "Proxy.svg";
              ReadingList = "ReadingList.svg";
              Reload = "Reload.svg";
              Rewind = "Rewind.svg";
              SearchField = "SearchField.svg";
              Settings = "Settings.svg";
              Stop = "Stop.svg";
              SyncStatus = "SyncStatus.svg";
              SyncedTabs = "SyncedTabs.svg";
              TabsTrash = "TabsTrash.svg";
              TilingToggle = "TilingToggle.svg";
              UpdateButton = "UpdateButton.svg";
              WorkspaceButton = "WorkspaceButton.svg";
            };
            colorAccentBg = "#${colors.base06}";
            colorBg = "#ffffff";
            colorFg = "#${colors.base02}";
            colorHighlightBg = "#${colors.base0B}";
            colorWindowBg = "#${colors.base07}";
            contrast = 1;
            dimBlurred = false;
            engineVersion = 1;
            id = "b4846bbc-2df4-46d4-b9ab-76e3837c3fea";
            name = "Stylix Light";
            preferSystemAccent = true;
            radius = 4;
            simpleScrollbar = false;
            transparencyTabBar = false;
            transparencyTabs = false;
            url = "";
            version = 1;
          };
        };
      };

      # force chromium to use wayland - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer
      # home.file.".config/chromium-flags.conf".text = ''
      #   --enable-features=UseOzonePlatform
      #   --ozone-platform=wayland
      #   --enable-features=WaylandWindowDecorations
      #   --ozone-platform-hint=auto
      #   --gtk-version=4
      # '';
      #  --force-device-scale-factor=1

      # home.file = let
      #   flags = ''
      #     --enable-features=UseOzonePlatform
      #     --ozone-platform=wayland
      #     --enable-features=WaylandWindowDecorations
      #     --ozone-platform-hint=auto
      #     # --gtk-version=4
      #   '';
      # in {
      #   ".config/chromium-flags.conf".text = flags;
      #   ".config/electron-flags.conf".text = flags;
      #   ".config/electron-flags16.conf".text = flags;
      # ".config/electron-flags17.conf".text = flags;
      # ".config/electron-flags18.conf".text = flags;
      # ".config/electron-flags19.conf".text = flags;
      # ".config/electron-flags20.conf".text = flags;
      # ".config/electron-flags21.conf".text = flags;
      #   ".config/electron-flags22.conf".text = flags;
      #   ".config/electron-flags23.conf".text = flags;
      #   ".config/electron-flags24.conf".text = flags;
      #   ".config/electron-flags25.conf".text = flags;
      # };
    };
  };
}
