{ config, pkgs, lib, ... }:
# Chromium user configuration with Wayland optimization
#
# This module configures Chromium for the user with:
# - Wayland-optimized flags for better performance on modern Linux desktops
# - Curated extension set for productivity and security
# - WideVine support for media playback
# - Electron app optimization via shared flag files
#
# The Wayland flags improve performance and compatibility on Wayland-based
# desktop environments like GNOME and sway.

let
  # Wayland flags for better performance and compatibility
  waylandFlags = [
    "--enable-features=UseOzonePlatform"
    "--ozone-platform=wayland"
    "--enable-features=WaylandWindowDecorations"
    "--ozone-platform-hint=auto"
    "--gtk-version=4"
    # Note: --no-sandbox removed - using AppArmor profile for proper sandboxing instead
  ];

in {
  # Chromium user configuration with Wayland optimization
    programs.chromium = {
      enable = true;

      # Optional: override package with WideVine support
      package = pkgs.unstable.chromium.override { enableWideVine = true; };

      # Optional command-line flags - Wayland optimization
      commandLineArgs = waylandFlags;

      # Optional: spellcheck dictionaries
    #   dictionaries = [
    #     pkgs.hunspellDictsChromium.en_US
    #   ];

      # Optional: Chrome/Chromium extensions - Essential productivity and security extensions
      extensions = [
        { id = "dgmanlpmmkibanfdgjocnabmcaclkmod"; } # Just Read
        { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
        { id = "glnpjglilkicbckjpbgcfkogebgllemb"; } # Okta
        { id = "kbfnbcaeplbcioakkpcpgfkobkghlhen"; } # Grammarly
        { id = "pbmlfaiicoikhdbjagjbglnbfcbcojpj"; } # Simplify
        { id = "jldhpllghnbhlbpcmnajkpdmadaolakh"; } # Todoist
        { id = "liecbddmkiiihnedobmlmillhodjkdmb"; } # Loom
        { id = "oeopbcgkkoapgobdbedcemjljbihmemj"; } # Checker Plus for Mail
        { id = "hkhggnncdpfibdhinjiegagmopldibha"; } # Checker Plus for Cal
        { id = "ghbmnnjooekpmoecnnnilnnbdlolhkhi"; } # Google Docs Offline
        { id = "pcmpcfapbekmbjjkdalcgopdkipoggdi"; } # Markdown Downloader
        { id = "egiemoacchfofdhhlfhkdcacgaopncmi"; } # URL/Tab Manager
        { id = "bcelhaineggdgbddincjkdmokbbdhgch"; } # Mail Message URL
        { id = "gphhapmejobijbbhgpjhcjognlahblep"; } # GNOME Extension Plugin
        { id = "miancenhdlkbmjmhlginhaaepbdnlllc"; } # Copy to Clipboard
        { id = "jpfpebmajhhopeonhlcgidhclcccjcik"; } # Speed Dial
        { id = "ldgfbffkinooeloadekpmfoklnobpien"; } # Raindrop
        { id = "kbiepllbcbandmpckhoejbgcaddcpbno"; } # Gainsight Assist
        { id = "bokiaeofleahagjcmcodjofilfdnoblk"; } # Material Theme Dark (black)
        { id = "bgnkhhnnamicmpeenaelnjfhikgbkllg"; } # Adguard AdBlocker
        { id = "gfapcejdoghpoidkfodoiiffaaibpaem"; } # Dracula Theme
      ];
    #   extensions = [
    #     { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
    #     {
    #       id = "dcpihecpambacapedldabdbpakmachpb";
    #       updateUrl = "https://example.com/updates.xml";
    #     }
    #     {
    #       id = "aaaaaaaaaabbbbbbbbbbcccccccccc";
    #       crxPath = "/home/youruser/share/extension.crx";
    #       version = "1.0";
    #     }
    #   ];
    };

    # Set Chromium as default browser
    home.sessionVariables.BROWSER = "chromium";

    # Create Wayland configuration files for Chromium and Electron apps
    home.file =
      let
        flags = lib.concatStringsSep "\n" waylandFlags;
        # Generate electron config files for common versions (16-30)
        electronVersions = lib.range 16 30;
        electronConfigs = lib.listToAttrs (map (version: {
          name = ".config/electron${toString version}-flags.conf";
          value = { text = flags; };
        }) electronVersions);
      in
      {
        ".config/chromium-flags.conf".text = flags;
        ".config/electron-flags.conf".text = flags;
      } // electronConfigs;
}