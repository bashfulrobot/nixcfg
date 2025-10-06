{
  user-settings,
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.desktops.tiling.hyprland;
  inherit (lib) getExe getExe';

  terminal = "kitty";
  terminalFileManager = "yazi";
  browser = getExe pkgs.chromium;
  kbdLayout = "us"; # US layout
  kbdVariant = ""; # Standard US variant

  makeScriptPackages = pkgs.callPackage ../lib/make-script-packages { };

  # Create script packages for hyprland module
  scriptPackages = makeScriptPackages {
    scriptsDir = ./scripts;
    scripts = [
      {
        name = "rofi-hyprland-keybinds";
        command = "hyprland-keybinds";
      }
    ];
    createFishAbbrs = false;
  };
in
{

  imports = [
    ../module-config/programs/waybar
    ../module-config/programs/wlogout
    ../module-config/programs/rofi
    ../module-config/programs/hypridle
    ../module-config/programs/hyprlock
    ../module-config/programs/swaync
    ../module-config/programs/swayosd
    ../module-config/programs/hyprdim
  ];

  # Enable D-Bus for proper desktop session integration
  services.dbus.enable = true;

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  systemd.user.services = {
    hyprpolkitagent = {
      description = "Hyprpolkitagent - Polkit authentication agent";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # GNOME Keyring SSH component - works with PAM-unlocked keyring
    # PAM handles secrets component unlock, this adds SSH functionality
    gnome-keyring-ssh = {
      description = "GNOME Keyring SSH component";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=ssh";
        Restart = "on-failure";
        RestartSec = 2;
        TimeoutStopSec = 10;
      };
    };

    # GNOME Keyring Secrets component - handles password storage and unlock
    gnome-keyring-secrets = {
      description = "GNOME Keyring Secrets component";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets";
        Restart = "on-failure";
        RestartSec = 2;
        TimeoutStopSec = 10;
      };
    };

  };

  # Disable the default NixOS keyring service to prevent conflicts
  systemd.user.services.gnome-keyring-daemon.enable = false;

  # GNOME Keyring is now started automatically by PAM during login
  # This ensures proper unlock integration with GDM password authentication
  services = {
    displayManager.defaultSession = "hyprland";
    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
      };
      excludePackages = [ pkgs.xterm ];
    };
    blueman.enable = false;
  };

  programs.hyprland = {
    enable = true;
    # withUWSM = true;
  };

  # Configure XDG Desktop Portals for better app compatibility
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };
  };

  environment.systemPackages =
    with pkgs;
    [
      pinentry-all # gpg passphrase prompting
      nautilus-open-any-terminal # open terminal(s) in nautilus
      file-roller # GNOME archive manager
      hyprpaper
      seahorse
      hyprpicker
      cliphist
      grimblast
      grim # needed for screensharing
      slurp # needed for screensharing
      swappy
      annotator # image annotation tool
      libnotify
      brightnessctl
      networkmanagerapplet
      pamixer
      nautilus
      pavucontrol
      playerctl
      waybar
      wtype
      wl-clipboard
      xdotool
      yad
      bibata-cursors
      ranger
      gnome-keyring
      gcr_4 # GCR 4.x for modern keyring password prompts
      libsecret
      blueman
      papirus-folders
      # Packages for swayosd custom indicators
      swayosd
      lm_sensors
      procps
      wirelesstools
      # Icon theme support for notifications
      hicolor-icon-theme
      shared-mime-info
      desktop-file-utils
      gtk3.out # for gtk-update-icon-cache
    ]
    ++ scriptPackages.packages;

  # Enable PAM keyring for automatic unlock on login
  security.pam.services = {
    gdm.enableGnomeKeyring = true;
    gdm-password.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  hw.bluetooth.enable = true;

  # Security wrapper for gnome-keyring-daemon with proper capabilities
  security.wrappers.gnome-keyring-daemon = {
    owner = "root";
    group = "root";
    capabilities = "cap_ipc_lock=ep";
    source = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon";
  };

  # Fix keyring unlock by ensuring XDG_RUNTIME_DIR is properly set during login
  environment.variables = {
    XDG_RUNTIME_DIR = "/run/user/$UID";
    # Ensure desktop portals get proper theming
    GTK_THEME = "Adwaita:dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";
    QT_QPA_PLATFORMTHEME = "gnome";
  };

  sys = {
    dconf.enable = true;
    stylix-theme.enable = true;
    xdg.enable = true;
  };

  system.activationScripts.script.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp ${./.face} /var/lib/AccountsService/icons/${user-settings.user.username}
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${user-settings.user.username}\n" > /var/lib/AccountsService/users/${user-settings.user.username}

    chown root:root /var/lib/AccountsService/users/${user-settings.user.username}
    chmod 0600 /var/lib/AccountsService/users/${user-settings.user.username}

    chown root:root /var/lib/AccountsService/icons/${user-settings.user.username}
    chmod 0444 /var/lib/AccountsService/icons/${user-settings.user.username}

    # Update icon caches for proper notification icons in lock screen
    if [ -x "${pkgs.gtk3.out}/bin/gtk-update-icon-cache" ]; then
      for theme_dir in /run/current-system/sw/share/icons/*; do
        if [ -d "$theme_dir" ]; then
          echo "Updating icon cache for $(basename "$theme_dir")"
          ${pkgs.gtk3.out}/bin/gtk-update-icon-cache -f -t "$theme_dir" 2>/dev/null || true
        fi
      done
      # Also update user-specific icon cache
      if [ -d "${user-settings.user.home}/.local/share/icons" ]; then
        for user_theme_dir in ${user-settings.user.home}/.local/share/icons/*; do
          if [ -d "$user_theme_dir" ]; then
            echo "Updating user icon cache for $(basename "$user_theme_dir")"
            ${pkgs.gtk3.out}/bin/gtk-update-icon-cache -f -t "$user_theme_dir" 2>/dev/null || true
          fi
        done
      fi
    fi
  '';

}
