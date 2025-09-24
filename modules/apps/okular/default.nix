# To add signature stamps in Okular:
# Go to Settings -> Configure Okular... -> Annotations -> Add -> Select Type: Stamp -> Choose symbol file from your file system using the file picker button.
# The signature.png and initials.png files will be available in ~/.kde/share/icons/

{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.apps.okular;
in
{
  options = {
    apps.okular.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Okular PDF viewer with signature stamps.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.okular # pdf viewer - can add sig stamps
    ];

    # Set up signature and initial icons
    home-manager.users."${user-settings.user.username}" = {
      home.file = {
        ".kde/share/icons/signature.png" = {
          source = ../../../secrets/sg.png;
        };
        ".kde/share/icons/initials.png" = {
          source = ../../../secrets/init.png;
        };
      };

      # Set Okular as default PDF viewer
      xdg.mimeApps = {
        associations = {
          added = {
            "application/pdf" = [ "okular.desktop" ];
          };
        };
        defaultApplications = {
          "application/pdf" = [ "okular.desktop" ];
        };
      };
    };
  };
}