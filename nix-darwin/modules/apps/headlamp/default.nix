{ user-settings, config, lib, pkgs, ... }:
let cfg = config.apps.headlamp;
in {
  options = {
    apps.headlamp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Mimestream Email Client.";
    };
  };

  config = lib.mkIf cfg.enable {

    # If an app isn't available in the Mac App Store, or the version in the App Store has
    # limitations, e.g., Transmit, install the Homebrew Cask.
    homebrew.casks = [ "headlamp" ];

    # system.defaults.CustomSystemPreferences = {
    #   # Mimestream
    #   "com.mimestream.Mimestream" = {
    #     DeleteKeyAction = "trash";
    #     DismissedDefaultEmailReaderBanner = 1;
    #     DontAskToTrashEntireConversation = 1;
    #     EnableSnoozing = 1;
    #     KeyboardShortcutSet = "gmail";
    #     SubscribedToNewsletter = 0;
    #     WebAutomaticLinkDetectionEnabled = 1;
    #     WebContinuousSpellCheckingEnabled = 1;
    #   };
    # };

  };
}
