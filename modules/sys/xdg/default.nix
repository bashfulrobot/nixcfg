{ user-settings, pkgs, config, lib, ... }:
let cfg = config.sys.xdg;
in {

  options = {
    sys.xdg.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable xdg.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ xdg-utils ];
    # Enable xdg
    xdg = {
      mime.enable = true;
      autostart.enable = true;
      icons.enable = true;
      menus.enable = true;
      sounds.enable = true;
    };

    home-manager.users."${user-settings.user.username}" = {
      xdg = {
        # TODO: remeber, forcing the file to be overwritten when home-manager is run
        # configFile."mimeapps.list".force = true;

        # desktopEntries.librewolf = {
        #   name = "LibreWolf";
        #   exec = "${pkgs.librewolf}/bin/librewolf";
        # };
        mimeApps = {
          associations = {
            # added = { "x-scheme-handler/tg" = "org.telegram.desktop.desktop"; };
          };
          enable = false;
          defaultApplications = {
            "text/html" = [ "chromium-browser.desktop" ];
            "text/plain" = [ "code.desktop" ];
            "text/markdown" = [ "code.desktop" ];
            # "inode/directory" = [ "lf.desktop" ];
            # "application/pdf" = [ "okular.desktop" ];
            "applications/x-www-browser" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/about" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/mailto" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
            "x-scheme-handler/postman" = [ "Postman.desktop" ];
            # "x-scheme-handler/unknown" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/slack" = [ "slack.desktop" ];
            # "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
            "x-scheme-handler/webcal" = [ "chromium-browser.desktop" ];
            "x-scheme-handler/terminal" = [ "ghostty.desktop" ];
          };
        };
      };
    };
  };
}
