{
  user-settings,
  pkgs,
  config,
  lib,
  secrets,
  ...
}:

let
  cfg = config.apps.syncthing;

in
{
  options = {
    apps = {
      syncthing = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Syncthing";
        };

        host = {
          donkey-kong = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable host donkey-kong";
          };

          qbert = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable host qbert";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      syncthing
      gnomeExtensions.syncthing-indicator
    ];

    # Syncthing ports
    # networking.firewall.allowedTCPPorts = [ 8384 22000 ];
    # networking.firewall.allowedUDPPorts = [ 22000 21027 ];

    services.syncthing = lib.mkMerge [
      {
        enable = true;
        settings.gui = {
          user = "${secrets.syncthing.user}";
          password = "${secrets.syncthing.password}";
        };
        systemService = true;
        # Sets the user that Syncthing runs as
        user = "${user-settings.user.username}";
        # Sets the group that Syncthing runs as
        group = "users";
        # Sets the Data Directory (the default sync directory, but we won’t use this)
        dataDir = "${user-settings.user.home}";
        # Sets the Web Interface to listen on all interfaces (for machines that are headless, I set to 0.0.0.0, otherwise 127.0.0.1)
        # Todo - bind to tailscale IP
        guiAddress = "0.0.0.0:8384";
        # Opens the default ports (21027/tcp & 22000) - note this doesn’t include the web interface
        openDefaultPorts = true;
        # override the devices and folders that are configured in the web interface.
        overrideDevices = true;
        overrideFolders = true;
      }
      (lib.mkIf cfg.host.donkey-kong {
        # Configuration when host donkey-kong is enabled
        # Sets the Config Directory (important because I sync it as a part of my .config files)
        # Note: if you don’t persist the configDir, the device ID will change after each nixos-rebuild switch.
        # ToDo - add a host variable, then add to sync
        configDir = "${user-settings.user.home}/.config/syncthing/donkey-kong";

        # Declaring the devices - no automated way to grab the device ID’s.
        # Hop into the web interface of each device and go to Settings -> Show ID,
        # then copy and paste it into my config.

        settings = {
          # NOTE - these are the devices you are sharing with, not the device you are on
          devices = {
            "qbert" = {
              # tailscale only
              addresses = [ "tcp://${secrets.qbert.tailscale_ip}:22000" ];
              id = "${secrets.qbert.syncthing_id}";
            };
            "maximus" = {
              # tailscale only
              addresses = [ "tcp://${secrets.maximus.tailscale_ip}:22000" ];
              id = "${secrets.maximus.syncthing_id}";
            };

          };
          folders = {
            "Desktop" = {
              path = "${user-settings.user.home}/Desktop";
              devices = [ "qbert" ];
              # keep just a handful of old versions of the config files. This ensures that I’m not eating up a ton of disk space, while giving me the ability to roll back far enough to resolve issues I create for myself.
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "Documents" = {
              path = "${user-settings.user.home}/Documents";
              devices = [ "qbert" ];

              #  The gist of staggered versioning is Syncthing will keep new versions created with an RPO of down to 30 seconds for the first hour, hourly versions for the first day, daily versions for the first month, and weekly versions until the maxAge is reached.

              # I set the cleanInterval parameter to hourly, meaning each hour it will purge old versions that have aged out. Then finally I configure the maxAge to 90 days calculated in seconds.
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            "Downloads" = {
              path = "${user-settings.user.home}/Downloads";
              devices = [ "qbert" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "phone" = {
              path = "${user-settings.user.home}/Phone";
              devices = [ "maximus" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "Music" = {
              path = "${user-settings.user.home}/Music";
              devices = [ "qbert" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "Pictures" = {
              path = "${user-settings.user.home}/Pictures";
              devices = [ "qbert" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "Videos" = {
              path = "${user-settings.user.home}/Videos";
              devices = [ "qbert" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "dev" = {
              path = "${user-settings.user.home}/dev";
              devices = [ "qbert" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            ".gnupg" = {
              path = "${user-settings.user.home}/.gnupg";
              devices = [ "qbert" ];
              ignorePerms = false; # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            ".aws" = {
              path = "${user-settings.user.home}/.aws";
              devices = [ "qbert" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            ".kube" = {
              path = "${user-settings.user.home}/.kube";
              devices = [ "qbert" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            ".doppler" = {
              path = "${user-settings.user.home}/.doppler";
              devices = [ "qbert" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            "virter" = {
              path = "${user-settings.user.home}/.config/virter";
              devices = [ "qbert" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            "bin" = {
              path = "${user-settings.user.home}/bin";
              devices = [ "qbert" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };

          };
        };

      })
      (lib.mkIf cfg.host.qbert {
        # Configuration when host qbert is enabled

        # Sets the Config Directory (important because I sync it as a part of my .config files)
        # Note: if you don’t persist the configDir, the device ID will change after each nixos-rebuild switch.
        # ToDo - add a host variable, then add to sync
        configDir = "${user-settings.user.home}/.config/syncthing/qbert";

        # Declaring the devices - no automated way to grab the device ID’s.
        # Hop into the web interface of each device and go to Settings -> Show ID,
        # then copy and paste it into my config.

        # NOTE - these are the devices you are sharing with, not the device you are on
        settings = {
          devices = {

            "donkey-kong" = {
              # tailscale only
              addresses = [ "tcp://${secrets.donkey-kong.tailscale_ip}:22000" ];
              id = "${secrets.donkey-kong.syncthing_id}";
            };
            "maximus" = {
              # tailscale only
              addresses = [ "tcp://${secrets.maximus.tailscale_ip}:22000" ];
              id = "${secrets.maximus.syncthing_id}";
            };

          };
          folders = {
            "Desktop" = {
              path = "${user-settings.user.home}/Desktop";
              devices = [ "donkey-kong" ];
              # keep just a handful of old versions of the config files. This ensures that I’m not eating up a ton of disk space, while giving me the ability to roll back far enough to resolve issues I create for myself.
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "Documents" = {
              path = "${user-settings.user.home}/Documents";
              devices = [ "donkey-kong" ];

              #  The gist of staggered versioning is Syncthing will keep new versions created with an RPO of down to 30 seconds for the first hour, hourly versions for the first day, daily versions for the first month, and weekly versions until the maxAge is reached.

              # I set the cleanInterval parameter to hourly, meaning each hour it will purge old versions that have aged out. Then finally I configure the maxAge to 90 days calculated in seconds.
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            "Downloads" = {
              path = "${user-settings.user.home}/Downloads";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "phone" = {
              path = "${user-settings.user.home}/Phone";
              devices = [ "maximus" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "Music" = {
              path = "${user-settings.user.home}/Music";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "Pictures" = {
              path = "${user-settings.user.home}/Pictures";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "Videos" = {
              path = "${user-settings.user.home}/Videos";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "simple";
                params = {
                  keep = "10";
                };
              };
            };
            "dev" = {
              path = "${user-settings.user.home}/dev";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            ".gnupg" = {
              path = "${user-settings.user.home}/.gnupg";
              devices = [ "donkey-kong" ];
              ignorePerms = false; # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            ".aws" = {
              path = "${user-settings.user.home}/.aws";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            ".kube" = {
              path = "${user-settings.user.home}/.kube";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            ".doppler" = {
              path = "${user-settings.user.home}/.doppler";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            "virter" = {
              path = "${user-settings.user.home}/.config/virter";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };
            "bin" = {
              path = "${user-settings.user.home}/bin";
              devices = [ "donkey-kong" ];
              versioning = {
                type = "staggered";
                params = {
                  cleanInterval = "3600";
                  maxAge = "7776000"; # 90 days
                };
              };
            };

          };
        };
      })
    ];

    home-manager.users."${user-settings.user.username}" = {
      home.file = {
        "syncthing.desktop" = {
          text = ''
            [Desktop Entry]
            Type=Application
            Name=Syncthing
            StartupWMClass=chrome-localhost__-Default
            Comment=Launch Syncthing Web UI
            Icon=${user-settings.user.home}/.local/share/xdg-desktop-portal/icons/192x192/syncthing.png
            Exec=chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --app="http://localhost:8384" %U

            Terminal=false
          '';
          target = ".local/share/applications/syncthing.desktop";
        };

        "syncthing.png" = {
          source = ./syncthing.png;
          target = ".local/share/xdg-desktop-portal/icons/192x192/syncthing.png";
        };

        "dev/.stignore" = {
          text = ''
            .git
            .DS_Store
          '';
          target = "dev/.stignore";
        };
      };
    };
  };
}
