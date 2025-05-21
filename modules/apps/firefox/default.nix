# Firefox module for NixOS/nix-darwin
{ user-settings, pkgs, config, lib, ... }:
let
  cfg = config.apps.firefox;

  defaultApplication = "firefox";

  firefoxIcon = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/a/a0/Firefox_logo%2C_2019.svg";
    sha256 = "sha256-VDBdnH8Ef2WyCp0wfv/8LYLf+J7fJj5L2tq3X3/v1wk="; # Replace with actual hash
  };

  firefoxDesktopItem = pkgs.makeDesktopItem {
    name = "firefox";
    desktopName = "Firefox";
    genericName = "Firefox Web Browser";
    comment = "Browse the Web";
    exec = "${pkgs.firefox}/bin/firefox %U";
    startupWMClass = "firefox";
    startupNotify = true;
    terminal = false;
    icon = firefoxIcon;
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
  };

  firefoxPackage = pkgs.stdenv.mkDerivation {
    name = "firefox-package";
    srcs = [ firefoxDesktopItem ];
    installPhase = ''
      mkdir -p $out/share/applications
      cp ${firefoxDesktopItem}/share/applications/firefox.desktop $out/share/applications/firefox.desktop
      mkdir -p $out/share/icons/hicolor/scalable/apps
      cp ${firefoxIcon} $out/share/icons/hicolor/scalable/apps/firefox.svg
    '';
  };

in {

  options = {
    apps.firefox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Firefox browser.";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      # firefoxPackage
      firefox
    ];

    home-manager.users."${user-settings.user.username}" = {

      home.sessionVariables = {
        BROWSER = "${defaultApplication}";
        # Force Firefox to use Wayland
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_WEBRENDER = "1";
        MOZ_USE_XINPUT2 = "1";
      };

      xdg.mimeApps.defaultApplications = {
        "text/html" = "${defaultApplication}.desktop";
        "x-scheme-handler/http" = "${defaultApplication}.desktop";
        "x-scheme-handler/https" = "${defaultApplication}.desktop";
        "x-scheme-handler/about" = "${defaultApplication}.desktop";
        "x-scheme-handler/unknown" = "${defaultApplication}.desktop";
      };

      programs.firefox = {
        enable = true;
        
        profiles = {
          default = {
            id = 0;
            name = "default";
            isDefault = true;
            
            settings = {
              # Privacy settings
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "privacy.donottrackheader.enabled" = true;
              "privacy.resistFingerprinting" = true;
              
              # Disable telemetry
              "toolkit.telemetry.enabled" = false;
              "toolkit.telemetry.unified" = false;
              "toolkit.telemetry.server" = "";
              "toolkit.telemetry.archive.enabled" = false;
              "toolkit.telemetry.newProfilePing.enabled" = false;
              "toolkit.telemetry.shutdownPingSender.enabled" = false;
              "toolkit.telemetry.updatePing.enabled" = false;
              "toolkit.telemetry.bhrPing.enabled" = false;
              "toolkit.telemetry.firstShutdownPing.enabled" = false;
              
              # Disable studies and experiments
              "app.shield.optoutstudies.enabled" = false;
              "app.normandy.enabled" = false;
              "app.normandy.api_url" = "";
              
              # Disable Pocket
              "extensions.pocket.enabled" = false;
              
              # Performance improvements
              "gfx.webrender.all" = true;
              "media.ffmpeg.vaapi.enabled" = true;
              "layers.acceleration.force-enabled" = true;
              
              # UI preferences
              "browser.toolbars.bookmarks.visibility" = "never";
              "browser.discovery.enabled" = false;
              "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
              "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
              "browser.newtabpage.activity-stream.showSponsored" = false;
              
              # Search settings
              "browser.search.suggest.enabled" = false;
              "browser.urlbar.suggest.searches" = false;
              "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
              "browser.urlbar.suggest.quicksuggest.sponsored" = false;
              
              # Security settings
              "security.tls.min_version" = 3;
              "security.ssl.require_safe_negotiation" = true;
              "dom.security.https_only_mode" = true;
              
              # Disable auto-updates (handled by Nix)
              "app.update.auto" = false;
              "app.update.enabled" = false;
              "app.update.silent" = false;
              
              # Language settings
              "intl.locale.requested" = "en-CA,en-US";
              "spellchecker.dictionary" = "en-CA,en-US";
              
              # Download behavior
              "browser.download.useDownloadDir" = false;
              "browser.download.alwaysOpenPanel" = false;
              
              # Content blocking
              "browser.contentblocking.category" = "strict";
              
              # Disable various Firefox features
              "browser.tabs.firefox-view" = false;
              "identity.fxaccounts.enabled" = false;
              "browser.places.importBookmarksHTML" = false;
              "browser.bookmarks.restore_default_bookmarks" = false;
              
              # Search engine configuration
              "browser.search.defaultenginename" = "DuckDuckGo";
              "browser.search.selectedEngine" = "DuckDuckGo";
            };

            # Search configuration
            search = {
              default = "DuckDuckGo";
              force = true;
              engines = {
                "Kagi" = {
                  urls = [{
                    template = "https://kagi.com/search";
                    params = [
                      { name = "q"; value = "{searchTerms}"; }
                    ];
                  }];
                  icon = "https://assets.kagi.com/v2/kagi-assets/favicon-32x32.png";
                  definedAliases = [ "k" ];
                };
                "Nix Packages" = {
                  urls = [{
                    template = "https://search.nixos.org/packages";
                    params = [
                      { name = "channel"; value = "unstable"; }
                      { name = "query"; value = "{searchTerms}"; }
                    ];
                  }];
                  icon = "https://nixos.org/logo/nixos-logo-only-hires.png";
                  definedAliases = [ "np" ];
                };
                "Nix Options" = {
                  urls = [{
                    template = "https://search.nixos.org/options";
                    params = [
                      { name = "channel"; value = "unstable"; }
                      { name = "query"; value = "{searchTerms}"; }
                    ];
                  }];
                  icon = "https://nixos.org/logo/nixos-logo-only-hires.png";
                  definedAliases = [ "no" ];
                };
                # Remove unwanted engines
                "Google".metaData.hidden = true;
                "Bing".metaData.hidden = true;
                "Amazon.com".metaData.hidden = true;
                "eBay".metaData.hidden = true;
                "Twitter".metaData.hidden = true;
              };
            };
            
            # Bookmarks configuration
            bookmarks = [
              {
                name = "Development";
                bookmarks = [
                  {
                    name = "NixOS Search";
                    url = "https://search.nixos.org/";
                  }
                  {
                    name = "Home Manager Options";
                    url = "https://nix-community.github.io/home-manager/options.html";
                  }
                  {
                    name = "Nix Manual";
                    url = "https://nixos.org/manual/nix/stable/";
                  }
                ];
              }
              {
                name = "Tools";
                bookmarks = [
                  {
                    name = "Firefox Add-ons";
                    url = "https://addons.mozilla.org/";
                  }
                ];
              }
            ];

            # Extensions (requires NUR for firefox-addons)
            # Uncomment and add NUR to your system to use these
            # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            #   ublock-origin
            #   # privacy-badger
            #   # bitwarden
            #   # onepassword-password-manager
            #   # darkreader
            #   # clearurls
            #   # decentraleyes
            # ];
          };
        };
      };
    };
  };
}