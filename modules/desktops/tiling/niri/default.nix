{
  user-settings,
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.desktops.tiling.niri;

  fuzzel-window-picker = pkgs.writeShellScriptBin "fuzzel-window-picker" ''
    windows=$(niri msg -j windows)
    niri msg action focus-window --id $(echo "$windows" | jq ".[$(echo "$windows" | jq -r 'map("\(.title // .app_id)\u0000icon\u001f\(.app_id)") | .[]' | fuzzel -d --index)].id")
  '';
in
{

  imports = [
    # ../module-config/programs/waybar
    # ../module-config/programs/wlogout
    # ../module-config/programs/rofi
    # ../module-config/programs/hypridle
    # ../module-config/programs/hyprlock
    # ../module-config/programs/swaync
    # ../module-config/programs/dunst
  ];

  options = {
    desktops.tiling.niri.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri Desktop";
    };
  };

  config = lib.mkIf cfg.enable {

    # nix.settings = {
    #   substituters = [ "https://hyprland.cachix.org" ];
    #   trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    # };

    # systemd.user.services.hyprpolkitagent = {
    #   description = "Hyprpolkitagent - Polkit authentication agent";
    #   wantedBy = [ "graphical-session.target" ];
    #   wants = [ "graphical-session.target" ];
    #   after = [ "graphical-session.target" ];
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
    #     Restart = "on-failure";
    #     RestartSec = 1;
    #     TimeoutStopSec = 10;
    #   };
    # };
    # services = {
    #   displayManager.defaultSession = "hyprland";
    #   gnome.gnome-keyring.enable = true;
    #   blueman.enable = true;
    # };

    programs = {
      niri.enable = true;
    };

    services = {
      gnome.gnome-keyring.enable = true;
    };

    environment = {
      # IME not working on Electron apps
      sessionVariables.NIXOS_OZONE_WL = "1";
      # However, since Niri does not support text-input-v1, sometimes enabling text-input-v3 by manually adding --text-input-version=v3 flag is necessary for IME to work:
      # slack --text-input-version=v3

      systemPackages = with pkgs; [
        swaybg
        fuzzel-window-picker
        bemoji
        catppuccin-cursors
        seahorse
        swww
        xdg-desktop-portal-gnome
      ];
    };

    security = {
      #pam.services.lightdm.enableGnomeKeyring = true;
      polkit.enable = true;
      pam.services.swaylock = { };
    };

    hw.bluetooth.enable = true;

    sys = {
      dconf.enable = true;
      theme-manager.enable = true;
      xdg.enable = true;
    };

    # programs.nautilus-open-any-terminal = {
    #   enable = true;
    #   terminal = "blackbox";
    # };

    ##### Home Manager Config options #####
    home-manager.users."${user-settings.user.username}" = {

      # Niri Configuration
      xdg.configFile."niri/config.kdl".source = ./module-config/niri/config.kdl;

      programs = {
        fuzzy.enable = true;
        swaylock.enable = true;
        waybar.enable = true;
      };

      services = {
        mako.enable = true;
        swayidle.enable = true;
        polkit-gnome.enable = true;
      };

      home.pointerCursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      gtk = {
        enable = true;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        theme = {
          name = "Catppuccin-Mocha-Standard-Sky-Dark";
          package = pkgs.catppuccin-gtk.override {
            accents = [ "sky" ];
            size = "standard";
            tweaks = [ "rimless" ];
            variant = "mocha";
          };
        };
      };

      xdg.configFile."hypr/icons" = {
        source = ../module-config/icons;
        recursive = true;
      };

      # dconf.settings = with inputs.home-manager.lib.hm.gvariant; {
      #   "org/gnome/desktop/interface" = {
      #     color-scheme = "prefer-dark";
      #     gtk-theme = "Catppuccin-Mocha-Standard-Sky-Dark";
      #   };
      # };

    };
  };
}
