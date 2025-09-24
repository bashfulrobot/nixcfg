{ user-settings, pkgs, lib, config, ... }:

let
  cfg = config.sys.scripts;

  makeScriptPackages = pkgs.callPackage ../../../lib/make-script-packages { };

  # Create script packages using the consolidated approach
  scriptPackages = makeScriptPackages {
    scriptsDir = ./scripts;
    scripts = [
      "get_wm_class"
      "restic-prune-nexstar"
      "init-bootstrap"
      "hw-scan"
      "gmail-url"
      "toggle-cursor-size"
      "screenshot-ocr"
      "screenshot-annotate"
      "copy_icons"
    ];
  };

in {
  options = {
    sys.scripts.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable consolidated system scripts.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install script packages
    environment.systemPackages = scriptPackages.packages ++ [
      # Runtime dependencies for scripts
      pkgs.wl-clipboard   # get_wm_class
      pkgs.fzf           # get_wm_class
      pkgs.restic        # restic-prune-nexstar
      pkgs.pass          # restic-prune-nexstar
      pkgs.docker        # hw-scan
      pkgs.xclip         # gmail-url, screenshot-ocr
      pkgs.gnugrep       # gmail-url
      pkgs.tesseract     # screenshot-ocr
      pkgs.satty         # screenshot-annotate
    ];

    home-manager.users."${user-settings.user.username}" = {
      home.packages = with pkgs; [
        # Additional packages for specific scripts
        bibata-cursors  # toggle-cursor-size
      ];
    };

    # Add fish shell abbreviations if fish is enabled
    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable
      scriptPackages.fishShellAbbrs;
  };
}