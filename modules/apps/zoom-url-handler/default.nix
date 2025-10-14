{ user-settings, config, pkgs, lib, ... }:

let
  cfg = config.apps.zoom-url-handler;

  # Standardized icon sizes for the zoom handler
  standardIconSizes = [ "16" "32" "48" "64" "96" "128" "256" ];

  # Zoom URL handler script using standard pattern
  zoomScripts = with pkgs; [
    (writeShellScriptBin "zoom-url-handler" (builtins.readFile ./scripts/zoom-url-handler.sh))
  ];

  # Create icon packages for all sizes
  zoomIcons = map (size:
    pkgs.stdenv.mkDerivation {
      name = "zoom-url-handler-icon-${size}";
      src = ./icons/${size}.png;
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/share/icons/hicolor/${size}x${size}/apps
        cp $src $out/share/icons/hicolor/${size}x${size}/apps/zoom-url-handler.png
        # Also install with custom WM class name for window manager matching
        cp $src $out/share/icons/hicolor/${size}x${size}/apps/zoom-web-client.png
      '';
    }) standardIconSizes;

in {

  options = {
    apps.zoom-url-handler.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zoom URL handler to open zoom links in browser.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Add zoom URL handler script and icons to system packages
    environment.systemPackages = zoomScripts ++ zoomIcons;

    home-manager.users."${user-settings.user.username}" = {
      # MIME type associations for Zoom URLs
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/zoom" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/zoommtg" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/zoomus" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/zoomphonecall" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/zoomauthenticator" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/tel" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/callto" = [ "zoom-url-handler.desktop" ];
        };
        associations.added = {
          "x-scheme-handler/zoom" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/zoommtg" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/zoomus" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/zoomphonecall" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/zoomauthenticator" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/tel" = [ "zoom-url-handler.desktop" ];
          "x-scheme-handler/callto" = [ "zoom-url-handler.desktop" ];
        };
      };

      # Custom desktop file for URL handling
      home.file.".local/share/applications/zoom-url-handler.desktop".text = ''
        [Desktop Entry]
        Name=Zoom URL Handler
        Comment=Handle Zoom URLs and open in web client
        Exec=zoom-url-handler %u
        Icon=/run/current-system/sw/share/icons/hicolor/64x64/apps/zoom-url-handler.png
        Terminal=false
        Type=Application
        NoDisplay=true
        StartupWMClass=zoom-web-client
        MimeType=x-scheme-handler/zoommtg;x-scheme-handler/zoomus;x-scheme-handler/zoom;x-scheme-handler/zoomphonecall;x-scheme-handler/zoomauthenticator;x-scheme-handler/tel;x-scheme-handler/callto;
        StartupNotify=true
      '';

      # Ensure desktop database is updated for protocol handlers
      home.activation.updateDesktopDatabase = lib.mkAfter ''
        $DRY_RUN_CMD ${pkgs.desktop-file-utils}/bin/update-desktop-database $HOME/.local/share/applications
      '';
    };
  };

}