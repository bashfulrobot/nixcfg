{ user-settings, config, pkgs, lib, makeDesktopItem, ... }:

let
  cfg = config.apps.zoom-web;

  # Import the makeDesktopApp function
  makeDesktopApp = pkgs.callPackage ../../../lib/cbb-webwrap { };

  # Zoom URL handler script using standard pattern
  zoomScripts = with pkgs; [
    (writeShellScriptBin "zoom-url-handler" (builtins.readFile ./scripts/zoom-url-handler.sh))
  ];

  zoomWebApp = makeDesktopApp {
    name = "Zoom";
    url = "https://app.zoom.us/wc/";
    binary = "${pkgs.unstable.chromium}/bin/chromium";
    iconPath = ./icons; # path to icons
    useAppFlag = true;
    acceptUrlParams = true;
    enableLogging = true; # Enable logging for debugging
  };

in {

  options = {
    apps.zoom-web.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zoom Web Client.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Add zoom web app and URL handler script to system packages
    environment.systemPackages = [ zoomWebApp.desktopItem ]
      ++ zoomWebApp.icons
      ++ zoomScripts;

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
        Icon=zoom
        Terminal=false
        Type=Application
        NoDisplay=true
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