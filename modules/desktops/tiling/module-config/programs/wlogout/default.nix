{lib, config, ...}: {
  home-manager.sharedModules = [
    (_: {
      xdg.configFile."wlogout/icons".source = ./icons;
      programs.wlogout = {
        enable = true;
        layout = [
          # {
          #   label = "lock";
          #   action = "${pkgs.hyprlock}/bin/hyprlock";
          #   text = "Lock";
          #   keybind = "l";
          # }
          # {
          #   label = "hibernate";
          #   action = "systemctl hibernate";
          #   text = "Hibernate";
          #   keybind = "h";
          # }
          {
            label = "logout";
            action = "hyprctl dispatch exit 0";
            # action = "killall -9 Hyprland sleep 2";
            text = "Exit";
            keybind = "e";
          }
          {
            label = "shutdown";
            action = "systemctl poweroff";
            text = "Shutdown";
            keybind = "s";
          }
          {
            label = "suspend";
            action = "systemctl suspend";
            text = "Suspend";
            keybind = "u";
          }
          {
            label = "reboot";
            action = "systemctl reboot";
            text = "Reboot";
            keybind = "r";
          }
        ];
        style = with config.lib.stylix.colors.withHashtag; lib.mkForce ''
          window {
            font-family: "${config.stylix.fonts.monospace.name}", monospace;
            font-size: 12pt;
            color: ${base05};
            background-color: alpha(${base00}, 0.95);
            border-radius: 12px;
            border: 2px solid ${base01};
            padding: 20px;
          }

          button {
            background-repeat: no-repeat;
            background-position: center;
            background-size: 32px;
            border: 2px solid ${base03};
            background-color: ${base01};
            margin: 8px;
            min-width: 80px;
            min-height: 80px;
            border-radius: 8px;
            transition: all 0.2s ease-in-out;
          }

          button:hover {
            background-color: ${base02};
            border-color: ${base04};
            transform: scale(1.05);
          }

          button:focus {
            background-color: ${base0D};
            border-color: ${base0D};
            color: ${base00};
            transform: scale(1.1);
          }
          #lock {
            background-image: image(url("icons/lock.png"));
          }
          #lock:focus {
            background-image: image(url("icons/lock-hover.png"));
          }

          #logout {
            background-image: image(url("icons/logout.png"));
          }
          #logout:focus {
            background-image: image(url("icons/logout-hover.png"));
          }

          #suspend {
            background-image: image(url("icons/sleep.png"));
          }
          #suspend:focus {
            background-image: image(url("icons/sleep-hover.png"));
          }

          #shutdown {
            background-image: image(url("icons/power.png"));
          }
          #shutdown:focus {
            background-image: image(url("icons/power-hover.png"));
          }

          #reboot {
            background-image: image(url("icons/restart.png"));
          }
          #reboot:focus {
            background-image: image(url("icons/restart-hover.png"));
          }
        '';
      };
    })
  ];
}
