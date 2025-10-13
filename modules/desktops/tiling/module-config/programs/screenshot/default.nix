{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.desktops.tiling.screenshot;
  tomlFormat = pkgs.formats.toml {};

  # Screenshot script packages using standard pattern
  screenshotScripts = with pkgs; [
    (writeShellScriptBin "screenshot-region" (builtins.readFile ./scripts/screenshot-region.sh))
    (writeShellScriptBin "screenshot-fullscreen" (builtins.readFile ./scripts/screenshot-fullscreen.sh))
    (writeShellScriptBin "screenshot-annotate" (builtins.readFile ./scripts/screenshot-annotate.sh))
    (writeShellScriptBin "screenshot-ocr" (builtins.readFile ./scripts/screenshot-ocr.sh))
  ];


in
{
  options = {
    desktops.tiling.screenshot.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable enhanced screenshot workflow with clipboard-first approach and annotation support.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      grim        # screenshot tool for Wayland
      grimblast   # enhanced grim wrapper
      libnotify   # for notify-send
      perl        # for OCR text processing
      slurp       # for area selection
      tesseract   # OCR engine
      wl-clipboard # for clipboard operations
      # keep-sorted end
    ] ++ screenshotScripts;

    # Enable satty module for annotation support
    apps.satty.enable = true;

    home-manager.users."${user-settings.user.username}" = {
      home.file = {
        # Create flag file for screenshot functionality
        ".config/nix-flags/screenshot-enabled".text = "";
      };
    };
  };
}