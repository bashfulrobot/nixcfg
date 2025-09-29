{
  config,
  pkgs,
  lib,
  user-settings,
  ...
}:
let
  cfg = config.suites.kong;
in
{

  options = {
    suites.kong.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable kong specific tools.";
    };
  };

  config = lib.mkIf cfg.enable {
    cli = { };

    apps = {
      # crowdstrike.enable = true;
      kong-email.enable = true;
      kong-drive.enable = true;
      kong-calendar.enable = true;
      kongfluence.enable = true;
      kong-docs.enable = true;
      new-kong-doc.enable = true;
      new-kong-sheet.enable = true;
      new-kong-slide.enable = true;
      sfdc.enable = true;
      gemini-pro.enable = true;
      lucidchart.enable = true;
      avanti.enable = true;
    };

    environment.systemPackages = with pkgs; [
      unstable.insomnia
    ];

    home-manager.users."${user-settings.user.username}" = {

    };
  };
}
