{ user-settings, pkgs, lib, config, ... }:

let
  cfg = config.sys.scripts;

  # System script packages using standard pattern
  systemScripts = with pkgs; [
    (writeShellScriptBin "get_wm_class" (builtins.readFile ./get_wm_class.sh))
    (writeShellScriptBin "restic-prune-nexstar" (builtins.readFile ./restic-prune-nexstar.sh))
    (writeShellScriptBin "init-bootstrap" (builtins.readFile ./init-bootstrap.sh))
    (writeShellScriptBin "hw-scan" (builtins.readFile ./hw-scan.sh))
    (writeShellScriptBin "gmail-url" (builtins.readFile ./gmail-url.sh))
    (writeShellScriptBin "toggle-cursor-size" (builtins.readFile ./toggle-cursor-size.sh))
    (writeShellScriptBin "screenshot-ocr" (builtins.readFile ./screenshot-ocr.sh))
    (writeShellScriptBin "screenshot-annotate" (builtins.readFile ./screenshot-annotate.sh))
    (writeShellScriptBin "copy_icons" (builtins.readFile ./copy_icons.sh))
  ];

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
    environment.systemPackages = systemScripts ++ [
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

    # Add fish shell abbreviations for convenience
    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable {
      "get_wm_class" = "get_wm_class";
      "rp-nexstar" = "restic-prune-nexstar";
      "init-bootstrap" = "init-bootstrap";
      "hw-scan" = "hw-scan";
      "gmail-url" = "gmail-url";
      "toggle-cursor" = "toggle-cursor-size";
      "ocr" = "screenshot-ocr";
      "annotate" = "screenshot-annotate";
      "copy_icons" = "copy_icons";
    };
  };
}