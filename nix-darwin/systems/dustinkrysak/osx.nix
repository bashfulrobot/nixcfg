{ config, pkgs, ... }:

{
  system.defaults = {
    # Autohide the dock
    dock.autohide = true;
    finder = {
      # Show all file exts in finder
      AppleShowAllExtensions = true;
      # Default to columns in finder
      FXPreferredViewStyle = "clmv";
    };

    controlcenter.Bluetooth = true;
    screencapture.location = "~/Pictures/screenshots";

    CustomUserPreferences = {
      NSGlobalDomain = {
        # Tap to Click
        "com.apple.mouse.tapBehavior" = 1;
        # Enable "natural" scrolling
        "com.apple.swipescrolldirection" = false;
        AppleShowAllExtensions = true;
        # Show hidden files in Finder
        AppleShowAllFiles = false;
        # light/dark mode automatically
        AppleInterfaceStyleSwitchesAutomatically = true;
        # 24 hour clock
        AppleICUForce24HourTime = true;
        # Add a context menu item for showing the Web Inspector in web views
        WebKitDeveloperExtras = true;
      };
      "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        # When performing a search, search the current folder by default
        FXDefaultSearchScope = "SCcf";
      };
      "com.apple.desktopservices" = {
        # Avoid creating .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.screencapture" = {
        location = "~/Pictures/screenshots";
        type = "png";
      };
      # "com.apple.Safari" = {
      #   # Privacy: don’t send search queries to Apple
      #   UniversalSearchEnabled = false;
      #   SuppressSearchSuggestions = true;
      #   # Press Tab to highlight each item on a web page
      #   WebKitTabToLinksPreferenceKey = true;
      #   ShowFullURLInSmartSearchField = true;
      #   # Prevent Safari from opening ‘safe’ files automatically after downloading
      #   AutoOpenSafeDownloads = false;
      #   ShowFavoritesBar = false;
      #   IncludeInternalDebugMenu = true;
      #   IncludeDevelopMenu = true;
      #   WebKitDeveloperExtrasEnabledPreferenceKey = true;
      #   WebContinuousSpellCheckingEnabled = true;
      #   WebAutomaticSpellingCorrectionEnabled = false;
      #   AutoFillFromAddressBook = false;
      #   AutoFillCreditCardData = false;
      #   AutoFillMiscellaneousForms = false;
      #   WarnAboutFraudulentWebsites = true;
      #   WebKitJavaEnabled = false;
      #   WebKitJavaScriptCanOpenWindowsAutomatically = false;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = false;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
      # };
      "com.apple.AdLib" = { allowApplePersonalizedAdvertising = false; };
      "com.apple.print.PrintingPrefs" = {
        # Automatically quit printer app once the print jobs complete
        "Quit When Finished" = true;
      };
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        # Check for software updates daily, not just once per week
        ScheduleFrequency = 1;
        # Download newly available updates in background
        AutomaticDownload = 1;
        # Install System data files & security updates
        CriticalUpdateInstall = 1;
      };
      # Prevent Photos from opening automatically when devices are plugged in
      "com.apple.ImageCapture".disableHotPlug = true;
      # Turn on app auto-update
      "com.apple.commerce".AutoUpdate = true;
    };

  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  ### CustomSystemPreferences
  # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-system.defaults.CustomSystemPreferences
  # list set items -  defaults read

  ###  Investigate
  # - https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.khd.i3Keybindings
  # - https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.sketchybar.enable
  # - https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.tailscale.enable
  # -https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.yabai.enable

}
