{ config, pkgs, lib, ... }:

let
  cfg = config.apps.chromium;
in {
  options.apps.chromium = {
    enable = lib.mkEnableOption "Enable Chromium browser (via Home Manager)";
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = true;

      # Optional: override package
      package = pkgs.unstable.chromium;

      # Optional command-line flags
      commandLineArgs = [

      ];

      # Optional: spellcheck dictionaries
    #   dictionaries = [
    #     pkgs.hunspellDictsChromium.en_US
    #   ];

      # Optional: Chrome/Chromium extensions
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
  };
}