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

      waybar = {
        Unit = {
          Description = "Waybar for niri";
          Documentation = "https://github.com/Alexays/Waybar/wiki";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session-pre.target" ];
        };

        Service = {
          Type = "simple";
          ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -x niri'";
          ExecStart = "${pkgs.waybar}/bin/waybar";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
          RestartSec = "1s";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

    };
  };

}
