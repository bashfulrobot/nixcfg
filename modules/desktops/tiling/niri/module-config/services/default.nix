{
  user-settings,
  pkgs,
  secrets,
  config,
  lib,
  inputs,
  ...
}:

{

  # NixOS Configuration

  # Display Manager Configuration for niri
  services = {
    displayManager.defaultSession = "niri";
    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
    };
    # Enable D-Bus for proper desktop session integration
    dbus.enable = true;
  };

  # PAM configuration for keyring integration
  # Note: niri-flake already enables GNOME keyring, this ensures GDM integration
  security.pam.services = {
    gdm.enableGnomeKeyring = true;
    gdm-password.enableGnomeKeyring = true;
  };

  sys = {
    dconf.enable = true;
    stylix-theme.enable = true;
    xdg.enable = true;
  };

  home-manager.users."${user-settings.user.username}" = {
    # Home Manager Configuration

    # Services
    services = {
      gnome-keyring = {
        enable = true;
        components = [
          "pkcs11"
          "secrets"
          "ssh"
        ];
      };
      cliphist = {
        enable = true;
      };
      blueman-applet = {
        enable = true;
      };
    };

    systemd.user.services = {
      cliphist = {
        User.ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
      };
      cliphist-images = {
        User.ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
      };
      polkit-gnome = {
        Unit = {
          Description = "PolicyKit Authentication Agent provided by niri-flake";
          WantedBy = [ "niri.service" ];
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -x niri'";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      swaync = {
        Unit = {
          Description = lib.mkForce "SwayNotificationCenter for niri";
          Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session-pre.target" ];
        };

        Service = {
          Type = lib.mkForce "simple";
          ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -x niri'";
          ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
          Restart = "on-failure";
          RestartSec = "1s";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };


      swww = {
        Unit = {
          Description = "Efficient animated wallpaper daemon for wayland";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Type = "simple";
          ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -x niri'";
          ExecStart = ''
            ${pkgs.swww}/bin/swww-daemon
          '';
          ExecStop = "${pkgs.swww}/bin/swww kill";
          Restart = "on-failure";
        };
      };

      niri-wallpaper = {
        Unit = {
          Description = "Set wallpaper for niri using swww";
          PartOf = [ "graphical-session.target" ];
          After = [ "swww.service" ];
          Requires = [ "swww.service" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -x niri'";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 2"; # Wait for swww daemon to be ready
          ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.swww}/bin/swww img ${config.sys.wallpapers.getWallpaper config.sys.stylix-theme.wallpaperType} --transition-type fade --transition-duration 1'";
        };
      };

      # SSH key auto-loading service
      ssh-key-loader = {
        Unit = {
          Description = "Auto-load SSH keys into GNOME keyring";
          PartOf = [ "graphical-session.target" ];
          After = [ "gnome-keyring.service" ];
          Requires = [ "gnome-keyring.service" ];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -x niri'";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 2"; # Wait for keyring to be ready
          ExecStart = "${../../../module-config/scripts/ssh-add-keys.sh}";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

    };
  };

}
