{ user-settings, pkgs, config, lib, ... }:
let cfg = config.cli.espanso;
in {
  options = {
    cli.espanso.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Espanso.";
    };
  };

  config = lib.mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [  ];

    home-manager.users."${user-settings.user.username}" = {
      services.espanso = {
        enable = true;
        waylandSupport = true;
        x11Support = true;
        configs = {
          default = {
            show_notifications = false;
          };
        };
        matches = {
          base = {
            matches = [
              {
                trigger = ":shrug";
                replace = "¯\\_(ツ)_/¯";
              }
              {
                trigger = ":tflip";
                replace = "(╯°□°）╯︵ ┻━┻";
              }
              {
                trigger = ":atflip";
                replace = "‎(ﾉಥ益ಥ）ﾉ﻿ ┻━┻";
              }

              {
                trigger = ":fingerguns";
                replace = "(☞ ͡° ͜ʖ ͡°)☞";
              }
            ];
          };
          personal = {
            matches = [
              {
                trigger = ":wem";
                replace = "dustin.krysak@konghq.com";
              }
              {
                trigger = ":pem";
                replace = "dustin@bashfulrobot.com";
              }
            ];
          };
          util = {
            matches = [{
              trigger = ":date";
              replace = "{{currentdate}}";
              vars = [{
                name = "currentdate";
                type = "date";
                params.format = "%Y-%m-%d";
              }];
            }];
          };
        };
      };

    };
  };
}
