{ config, pkgs, lib, ... }:

let
  cfg = config.apps.chromium;

  # Wayland flags for better performance
  waylandFlags = [
    "--enable-features=UseOzonePlatform"
    "--ozone-platform=wayland"
    "--enable-features=WaylandWindowDecorations"
    "--ozone-platform-hint=auto"
    "--gtk-version=4"
    # Note: --no-sandbox removed - using AppArmor profile for proper sandboxing instead
  ];

in {
  options.apps.chromium = {
    enable = lib.mkEnableOption "Enable Chromium browser (via Home Manager)";
  };

  config = lib.mkIf cfg.enable {
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
      in
      {
        ".config/chromium-flags.conf".text = flags;
        ".config/electron-flags.conf".text = flags;
        ".config/electron16-flags.conf".text = flags;
        ".config/electron17-flags.conf".text = flags;
        ".config/electron18-flags.conf".text = flags;
        ".config/electron19-flags.conf".text = flags;
        ".config/electron20-flags.conf".text = flags;
        ".config/electron21-flags.conf".text = flags;
        ".config/electron22-flags.conf".text = flags;
        ".config/electron23-flags.conf".text = flags;
        ".config/electron24-flags.conf".text = flags;
        ".config/electron25-flags.conf".text = flags;
      };
  };
}