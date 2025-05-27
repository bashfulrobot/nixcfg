{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.vivaldi;
in
{

  options = {
    apps.vivaldi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable vivaldi browser.";
      };
    };

  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      (unstable.vivaldi.override {
        proprietaryCodecs = true;
        inherit (unstable) vivaldi-ffmpeg-codecs;
        enableWidevine = true; # Seen some reports that can cause a crash
        commandLineArgs = [
          "--ozone-platform=wayland"
          "--enable-features=WaylandWindowDecorations"
          "--ozone-platform-hint=auto"
          "--enable-features=WaylandWindowDecorations"

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
    # Catppuccin Github icons
    #"lnjaiaapbakfhlbjenjkhffcdpoompki"
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
    # Catppuccin Mocha theme
    #"bkkmolkhemgaeaeggcmfbghljjjoofoh"
    # Perplexity AI
    #"bnaffjbjpgiagpondjlnneblepbdchol"
    # Catppuccin Frappe theme
    # "olhelnoplefjdmncknfphenjclimckaf"
    # Catppuccin Macchiato theme
    # "cmpdlhmnmjhihmcfnigoememnffkimlk"
    # Catppuccin Latte theme
    # "jhjnalhegpceacdhbplhnakmkdliaddd"
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

      # home.sessionVariables.BROWSER = "${defaultApplication}";

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
