# Screenshare guide for hyprland
# https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580
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

  terminal = "ghostty";
  terminalFileManager = "ranger";
  browser = getExe pkgs.chromium;
  kbdLayout = "us"; # US layout
  kbdVariant = ""; # Standard US variant

  makeScriptPackages = pkgs.callPackage ../../../../lib/make-script-packages { };

  # Create script packages for hyprland module
  scriptPackages = makeScriptPackages {
    scriptsDir = ./scripts;
    scripts = [
      { name = "rofi-hyprland-keybinds"; command = "hyprland-keybinds"; }
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
    # ../module-config/programs/dunst
  ];

  options = {
    desktops.tiling.hyprland.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Hyprland Desktop";
    };
  };

  config = lib.mkIf cfg.enable {

    # sys.gtk-theme.enable = true;

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
          default = [ "hyprland" "gtk" ];
        };
        hyprland = {
          default = [ "hyprland" "gtk" ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
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
      # hyprshell managed by Home Manager module
      # socat # for and autowaybar.sh
      # jq # for and autowaybar.sh
    ] ++ scriptPackages.packages;

    # security.pam.services.sddm.enableGnomeKeyring = true;
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

    ##### Home Manager Config options #####
    home-manager.users."${user-settings.user.username}" = {

      # https://discourse.nixos.org/t/cant-get-gnupg-to-work-no-pinentry/15373/13?u=brnix
      # home.file.".gnupg/gpg-agent.conf".text = ''
      #   pinentry-program /run/current-system/sw/bin/pinentry
      # '';

      home.pointerCursor = {
        name = lib.mkDefault "Bibata-Modern-Classic";
        package = lib.mkDefault pkgs.bibata-cursors;
        size = lib.mkDefault 24;
        gtk.enable = lib.mkDefault true;
        x11.enable = lib.mkDefault true;
      };

      gtk = {
        enable = true;
        iconTheme = {
          name = lib.mkDefault "Papirus-Dark";
          package = lib.mkDefault pkgs.papirus-icon-theme;
        };
        theme = {
          name = lib.mkDefault "Adwaita-dark";
        };
      };

      xdg.configFile."hypr/icons" = {
        source = ../module-config/icons;
        recursive = true;
      };

      wayland.windowManager.hyprland = {
        enable = true;
        plugins = [
          # inputs.hyprland-plugins.packages.${pkgs.system}.hyprwinwrap
        ];
        systemd = {
          enable = true;
          variables = [ "--all" ];
        };
        settings = {
          "$mainMod" = "SUPER";
          "$term" = "${getExe pkgs.${terminal}}";
          "$editor" = "code --disable-gpu";
          "$fileManager" = "$term --class \"terminalFileManager\" -e ${terminalFileManager}";
          "$browser" = browser;

          env = [
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
            "GDK_BACKEND,wayland,x11,*"
            "NIXOS_OZONE_WL,1"
            "ELECTRON_OZONE_PLATFORM_HINT,auto"
            "MOZ_ENABLE_WAYLAND,1"
            "OZONE_PLATFORM,wayland"
            "EGL_PLATFORM,wayland"
            "CLUTTER_BACKEND,wayland"
            "SDL_VIDEODRIVER,wayland"
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORMTHEME,qt6ct"
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "WLR_RENDERER_ALLOW_SOFTWARE,1"
            "NIXPKGS_ALLOW_UNFREE,1"
            "XCURSOR_THEME,Bibata-Modern-Classic"
            "XCURSOR_SIZE,24"
            "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/keyring/ssh"
            "SSH_ASKPASS,${pkgs.gcr_4}/libexec/gcr4-ssh-askpass"
            "DISPLAY,:0"
            "GNOME_KEYRING_CONTROL,$XDG_RUNTIME_DIR/keyring"
            "SIGNAL_PASSWORD_STORE,gnome-libsecret"
            # Additional theming variables for comprehensive dark mode support
            "GTK_THEME,Adwaita:dark"
            "QT_STYLE_OVERRIDE,adwaita-dark"
            "QT_QPA_PLATFORMTHEME,gnome"
            "ELECTRON_FORCE_DARK_MODE,1"
            "ELECTRON_ENABLE_DARK_MODE,1"
            "ELECTRON_USE_SYSTEM_THEME,1"
            "ELECTRON_DISABLE_DEFAULT_MENU_BAR,1"
            # Java applications
            "_JAVA_OPTIONS,-Dswing.aatext=true -Dawt.useSystemAAFontSettings=on"
          ];
          exec-once = [
            #"[workspace 1 silent] ${terminal}"
            #"[workspace 5 silent] ${browser}"
            #"[workspace 6 silent] spotify"
            #"[workspace special silent] ${browser} --private-window"
            #"[workspace special silent] ${terminal}"

            # Needed for screensharing
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "swaync"
            "nm-applet --indicator"
            #"blueman-applet"
            "pwvucontrol --hide-window"
            "wl-clipboard-history -t"
            "${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch cliphist store" # clipboard store text data
            "${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch cliphist store" # clipboard store image data
            "rm '$XDG_CACHE_HOME/cliphist/db'" # Clear clipboard
            "${../module-config/scripts/batterynotify.sh}" # battery notification
            # "${../module-config/scripts/autowaybar.sh}" # uncomment packages at the top
            "polkit-agent-helper-1"
            "${pkgs.gcr_4}/libexec/gcr4-ssh-askpass" # GCR SSH askpass for keyring password prompts
            "${../module-config/scripts/ssh-add-keys.sh}" # Auto-load SSH keys into keyring
            "pamixer --set-volume 50"
          ]
          ++ lib.optionals config.apps.one-password.enable [
            "1password"
          ];
          input = {
            kb_layout = "${kbdLayout},us";
            kb_variant = "${kbdVariant},";
            repeat_delay = 300; # or 212
            repeat_rate = 30;

            follow_mouse = 1;

            touchpad.natural_scroll = false;

            tablet.output = "current";

            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
            force_no_accel = true;
          };
          general = {
            gaps_in = 4;
            gaps_out = 9;
            border_size = 2;
            "col.active_border" = lib.mkDefault "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.inactive_border" = lib.mkForce "rgba(${config.lib.stylix.colors.base00}66)";
            resize_on_border = true;
            layout = "dwindle"; # dwindle or master
            # allow_tearing = true; # Allow tearing for games (use immediate window rules for specific games or all titles)
          };
          decoration = {
            shadow.enabled = false;
            rounding = 10;
            dim_special = 0.3;
            blur = {
              enabled = true;
              special = true;
              size = 6; # 6
              passes = 2; # 3
              new_optimizations = true;
              ignore_opacity = true;
              xray = false;
            };
          };
          group = {
            "col.border_active" = lib.mkDefault "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.border_inactive" = lib.mkDefault "rgba(b4befecc) rgba(6c7086cc) 45deg";
            "col.border_locked_active" = lib.mkDefault "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.border_locked_inactive" = lib.mkDefault "rgba(b4befecc) rgba(6c7086cc) 45deg";
          };
          layerrule = [
            "blur, rofi"
            "ignorezero, rofi"
            "ignorealpha 0.7, rofi"

            # "blur, swaync-control-center"
            # "blur, swaync-notification-window"
            # "ignorezero, swaync-control-center"
            # "ignorezero, swaync-notification-window"
            # "ignorealpha 0.9, swaync-control-center"
            # "ignorealpha 0.9, swaync-notification-window"
          ];
          animations = {
            enabled = true;
            bezier = [
              "linear, 0, 0, 1, 1"
              "md3_standard, 0.2, 0, 0, 1"
              "md3_decel, 0.05, 0.7, 0.1, 1"
              "md3_accel, 0.3, 0, 0.8, 0.15"
              "overshot, 0.05, 0.9, 0.1, 1.1"
              "crazyshot, 0.1, 1.5, 0.76, 0.92"
              "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
              "fluent_decel, 0.1, 1, 0, 1"
              "easeInOutCirc, 0.85, 0, 0.15, 1"
              "easeOutCirc, 0, 0.55, 0.45, 1"
              "easeOutExpo, 0.16, 1, 0.3, 1"
            ];
            animation = [
              "windows, 1, 3, md3_decel, popin 60%"
              "border, 1, 10, default"
              "fade, 1, 2.5, md3_decel"
              # "workspaces, 1, 3.5, md3_decel, slide"
              "workspaces, 1, 3.5, easeOutExpo, slide"
              # "workspaces, 1, 7, fluent_decel, slidefade 15%"
              # "specialWorkspace, 1, 3, md3_decel, slidefadevert 15%"
              "specialWorkspace, 1, 3, md3_decel, slidevert"
            ];
          };
          render = {
            # explicit_sync options removed in newer Hyprland versions
            direct_scanout = 2; # 0 = off, 1 = on, 2 = auto (on with content type 'game')
          };
          misc = {
            disable_hyprland_logo = true;
            mouse_move_focuses_monitor = true;
            swallow_regex = "^(Alacritty|kitty)$";
            enable_swallow = true;
            vfr = true; # always keep on
            vrr = 1; # enable variable refresh rate (0=off, 1=on, 2=fullscreen only)
            focus_on_activate = true; # allow notifications to focus apps when clicked
          };
          xwayland.force_zero_scaling = false;
          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
            workspace_swipe_distance = 300;
            workspace_swipe_forever = true;
            workspace_swipe_cancel_ratio = 0.15;
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
            permanent_direction_override = true; # Enable for better auto-splits
            smart_split = false; # Let Hyprland handle splits intelligently
            smart_resizing = true; # Add this for better resizing
            force_split = 2; # Add this for consistent splitting
          };
          master = {
            new_status = "master";
            new_on_top = true;
            mfact = 0.5;
          };
          windowrule = [
            #"noanim, class:^(Rofi)$
            "tile,title:(.*)(Godot)(.*)$"
            # "workspace 1, class:^(kitty|Alacritty|org.wezfurlong.wezterm)$"
            # "workspace 2, class:^(code|VSCodium|code-url-handler|codium-url-handler)$"
            # "workspace 3, class:^(krita)$"
            # "workspace 3, title:(.*)(Godot)(.*)$"
            # "workspace 3, title:(GNU Image Manipulation Program)(.*)$"
            # "workspace 3, class:^(factorio)$"
            # "workspace 3, class:^(steam)$"
            # "workspace 5, class:^(firefox|floorp|zen)$"
            # Auto-send apps to special workspaces
            "workspace special:spotify, class:^(Spotify)$"
            "workspace special:spotify, title:(.*)(Spotify)(.*)$"
            "workspace special:1password, class:^(1Password)$"
            "workspace special:1password, title:(.*)(1Password)(.*)$"

            # Can use FLOAT FLOAT for active and inactive or just FLOAT
            "opacity 0.80 0.80,class:^(kitty|alacritty|Alacritty|org.wezfurlong.wezterm)$"
            "opacity 0.90 0.90,class:^(gcr-prompter)$" # keyring prompt
            "opacity 0.90 0.90,title:^(Hyprland Polkit Agent)$" # polkit prompt
            "opacity 1.00 1.00,class:^(firefox)$"
            "opacity 0.90 0.90,class:^(Brave-browser)$"
            "opacity 0.80 0.80,class:^(Steam)$"
            "opacity 0.80 0.80,class:^(steam)$"
            "opacity 0.80 0.80,class:^(steamwebhelper)$"
            "opacity 0.80 0.80,class:^(Spotify)$"
            "opacity 0.80 0.80,title:(.*)(Spotify)(.*)$"
            "opacity 0.80 0.80,class:^(VSCodium)$"
            "opacity 0.80 0.80,class:^(codium-url-handler)$"
            "opacity 0.80 0.80,class:^(code)$"
            "opacity 0.80 0.80,class:^(code-url-handler)$"
            "opacity 0.80 0.80,class:^(terminalFileManager)$"
            "opacity 0.80 0.80,class:^(org.kde.dolphin)$"
            "opacity 0.80 0.80,class:^(org.kde.ark)$"
            "opacity 0.80 0.80,class:^(nwg-look)$"
            "opacity 0.80 0.80,class:^(qt5ct)$"
            "opacity 0.80 0.80,class:^(qt6ct)$"
            "opacity 0.80 0.80,class:^(yad)$"

            "opacity 0.90 0.90,class:^(com.github.rafostar.Clapper)$" # Clapper-Gtk
            "opacity 0.80 0.80,class:^(com.github.tchx84.Flatseal)$" # Flatseal-Gtk
            "opacity 0.80 0.80,class:^(hu.kramo.Cartridges)$" # Cartridges-Gtk
            "opacity 0.80 0.80,class:^(com.obsproject.Studio)$" # Obs-Qt
            "opacity 0.80 0.80,class:^(gnome-boxes)$" # Boxes-Gtk
            "opacity 0.90 0.90,class:^(discord)$" # Discord-Electron
            "opacity 0.90 0.90,class:^(WebCord)$" # WebCord-Electron
            "opacity 0.80 0.80,class:^(app.drey.Warp)$" # Warp-Gtk
            "opacity 0.80 0.80,class:^(net.davidotek.pupgui2)$" # ProtonUp-Qt
            "opacity 0.80 0.80,class:^(Signal)$" # Signal-Gtk
            "opacity 0.80 0.80,class:^(io.gitlab.theevilskeleton.Upscaler)$" # Upscaler-Gtk

            "opacity 0.80 0.70,class:^(pavucontrol)$"
            "opacity 0.80 0.70,class:^(org.pulseaudio.pavucontrol)$"
            "opacity 0.80 0.70,class:^(blueman-manager)$"
            "opacity 0.80 0.70,class:^(.blueman-manager-wrapped)$"
            "opacity 0.80 0.70,class:^(nm-applet)$"
            "opacity 0.80 0.70,class:^(nm-connection-editor)$"
            "opacity 0.80 0.70,class:^(org.kde.polkit-kde-authentication-agent-1)$"

            "tag +games, content:game"
            "tag +games, class:^(steam_app.*|steam_app_\d+)$"
            "tag +games, class:^(gamescope)$"
            "tag +games, class:(Waydroid)"
            "tag +games, class:(osu!)"

            # Games
            "syncfullscreen,tag:games"
            "fullscreen,tag:games"
            "noborder 1,tag:games"
            "noshadow,tag:games"
            "noblur,tag:games"
            "noanim,tag:games"

            "float,class:^(qt5ct)$"
            "float,class:^(nwg-look)$"
            "float,class:^(org.kde.ark)$"
            "float,class:^(Signal)$" # Signal-Gtk
            "float,class:^(com.github.rafostar.Clapper)$" # Clapper-Gtk
            "float,class:^(app.drey.Warp)$" # Warp-Gtk
            "float,class:^(net.davidotek.pupgui2)$" # ProtonUp-Qt
            "float,class:^(eog)$" # Imageviewer-Gtk
            "float,class:^(io.gitlab.theevilskeleton.Upscaler)$" # Upscaler-Gtk
            "float,class:^(yad)$"
            "float,class:^(pavucontrol)$"
            "float,class:^(blueman-manager)$"
            "float,class:^(.blueman-manager-wrapped)$"
            "float,class:^(nm-applet)$"
            "float,class:^(nm-connection-editor)$"
            "float,class:^(org.kde.polkit-kde-authentication-agent-1)$"

          ];
          binde = [
            # PResize windows
            "$mainMod SHIFT, right, resizeactive, 30 0"
            "$mainMod SHIFT, left, resizeactive, -30 0"
            "$mainMod SHIFT, up, resizeactive, 0 -30"
            "$mainMod SHIFT, down, resizeactive, 0 30"

            # Removed resize bindings - moved to submap

            # Functional keybinds with swayosd
            ",XF86MonBrightnessDown,exec,swayosd-client --brightness lower"
            ",XF86MonBrightnessUp,exec,swayosd-client --brightness raise"
            ",XF86AudioLowerVolume,exec,swayosd-client --output-volume lower"
            ",XF86AudioRaiseVolume,exec,swayosd-client --output-volume raise"
          ];
          bind =
            let
              autoclicker = pkgs.callPackage ../module-config/scripts/autoclicker.nix { };
              swayosd-custom = pkgs.writeShellScript "swayosd-custom" ''
                # Custom swayosd indicators script
                # Usage: ./swayosd-custom.sh <command> [args]

                case "$1" in
                  "battery")
                    # Show battery level as progress bar
                    battery_level=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
                    if [[ -n "$battery_level" ]]; then
                      ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$battery_level"
                    fi
                    ;;

                  "microphone-volume")
                    # Show microphone volume level
                    mic_volume=$(${pkgs.pamixer}/bin/pamixer --default-source --get-volume 2>/dev/null || echo "0")
                    ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$mic_volume"
                    ;;

                  "cpu-temp")
                    # Show CPU temperature as progress (scaled to 0-100)
                    temp=$(${pkgs.lm_sensors}/bin/sensors 2>/dev/null | grep -i "core 0" | awk '{print $3}' | tr -d '+°C' | cut -d'.' -f1)
                    if [[ -n "$temp" && "$temp" =~ ^[0-9]+$ ]]; then
                      # Scale temperature: 30°C = 0%, 80°C = 100%
                      scaled_temp=$(( (temp - 30) * 2 ))
                      [[ $scaled_temp -lt 0 ]] && scaled_temp=0
                      [[ $scaled_temp -gt 100 ]] && scaled_temp=100
                      ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$scaled_temp"
                    fi
                    ;;

                  "memory-usage")
                    # Show memory usage percentage
                    mem_usage=$(${pkgs.procps}/bin/free | grep "Mem:" | awk '{printf "%.0f", $3/$2 * 100}')
                    ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$mem_usage"
                    ;;

                  "wifi-strength")
                    # Show WiFi signal strength
                    wifi_strength=$(${pkgs.wirelesstools}/bin/iwconfig 2>/dev/null | grep "Signal level" | sed 's/.*Signal level=\([0-9-]*\).*/\1/' | head -1)
                    if [[ -n "$wifi_strength" ]]; then
                      # Convert dBm to percentage (rough approximation)
                      # -30 dBm = 100%, -90 dBm = 0%
                      percentage=$(( (wifi_strength + 90) * 100 / 60 ))
                      [[ $percentage -lt 0 ]] && percentage=0
                      [[ $percentage -gt 100 ]] && percentage=100
                      ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$percentage"
                    fi
                    ;;

                  "disk-usage")
                    # Show disk usage for specified path (default: home directory)
                    path="''${2:-$HOME}"
                    disk_usage=$(${pkgs.coreutils}/bin/df "$path" | awk 'NR==2 {print int($5)}' | tr -d '%')
                    ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$disk_usage"
                    ;;

                  "screenshot-taken")
                    # Show screenshot confirmation
                    ${pkgs.swayosd}/bin/swayosd-client --output-volume 0 --max-volume 100 > /dev/null 2>&1 || true
                    ${pkgs.libnotify}/bin/notify-send "Screenshot" "Screenshot captured" --icon=camera-photo
                    ;;

                  "launcher-opened")
                    # Show launcher opened notification
                    ${pkgs.swayosd}/bin/swayosd-client --output-volume 0 --max-volume 100 > /dev/null 2>&1 || true
                    ${pkgs.libnotify}/bin/notify-send "Launcher" "Application launcher opened" --icon=applications-system
                    ;;

                  *)
                    echo "Usage: $0 {battery|microphone-volume|cpu-temp|memory-usage|wifi-strength|disk-usage [path]|screenshot-taken|launcher-opened}"
                    echo "Custom swayosd progress indicators for system monitoring and notifications"
                    exit 1
                    ;;
                esac
              '';
            in
            [
              # Keybinds help menu
              "$mainMod, question, exec, hyprland-keybinds"
              "$mainMod, slash, exec, hyprland-keybinds"
              "$mainMod CTRL, question, exec, hyprland-keybinds"
              # Fish commands help menu
              "$mainMod ALT, question, exec, fish-help-rofi"
              "$mainMod ALT, slash, exec, fish-help-rofi"
              # Espanso shortcuts menu
              "$mainMod SHIFT, question, exec, ${../module-config/scripts/espanso-rofi.sh}"

              "$mainMod, F8, exec, kill $(cat /tmp/auto-clicker.pid) 2>/dev/null || ${lib.getExe autoclicker} --cps 40"
              # "$mainMod ALT, mouse:276, exec, kill $(cat /tmp/auto-clicker.pid) 2>/dev/null || ${lib.getExe autoclicker} --cps 60"

              # Night Mode (lower value means warmer temp)
              "$mainMod, F9, exec, ${getExe pkgs.hyprsunset} --temperature 3500" # good values: 3500, 3000, 2500
              "$mainMod, F10, exec, pkill hyprsunset"

              # Window/Session actions
              "$mainMod, Q, exec, ${../module-config/scripts/dontkillsteam.sh}" # killactive, kill the window on focus
              "ALT, F4, exec, ${../module-config/scripts/dontkillsteam.sh}" # killactive, kill the window on focus
              "$mainMod, delete, exit" # kill hyperland session
              "$mainMod, W, togglefloating" # toggle the window on focus to float
              "$mainMod SHIFT, G, togglegroup" # toggle the window on focus to float
              "ALT, return, fullscreen" # toggle the window on focus to fullscreen
              "$mainMod ALT, L, exec, hyprlock" # lock screen
              "$mainMod, backspace, exec, pkill -x wlogout || wlogout -b 4" # logout menu
              "$mainMod ALT, S, exec, systemctl suspend" # suspend system
              "$mainMod ALT, M, exec, hyprctl dispatch dpms off" # turn off monitors
              "$mainMod ALT SHIFT, M, exec, hyprctl dispatch dpms on" # turn on monitors
              "$CONTROL, ESCAPE, exec, pkill waybar || waybar" # toggle waybar

              # Applications/Programs
              "$mainMod, Return, exec, $term"
              "$mainMod, T, exec, $term"
              "$mainMod, E, exec, notify-send '󰉋 Explore Mode' 'd=Downloads, o=Documents, v=dev, s=Screenshots, n=nixcfg, ESC/Enter=Exit' -u normal -t 8000 -i folder --skip-summary"
              "$mainMod, E, submap, 󰉋 Explore"
              "$mainMod, C, exec, $editor"
              "$mainMod, B, exec, $browser"
              "$mainMod, F, fullscreen"
              "$mainMod SHIFT, S, exec, spotify"
              "$mainMod SHIFT, Y, exec, youtube-music"
              "$CONTROL ALT, DELETE, exec, $term -e '${getExe pkgs.btop}'" # System Monitor
              "$mainMod CTRL, C, exec, hyprpicker --autocopy --format=hex" # Colour Picker

              "$mainMod, A, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} drun" # launch desktop applications
              "$mainMod, SPACE, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} drun" # launch desktop applications
              "$mainMod CTRL, SPACE, exec, pkill -x rofi || rofi -show window -show-icons" # window switcher with icons
              "$mainMod, Z, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} emoji" # launch emoji picker
              # "$mainMod, tab, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} window" # switch between desktop applications
              # "$mainMod, R, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} file" # brrwse system files
              "$mainMod ALT, K, exec, ${../module-config/scripts/keyboardswitch.sh}" # change keyboard layout
              "$mainMod ALT, B, exec, blueman-manager" # bluetooth manager
              "$mainMod SHIFT, N, exec, swaync-client -t -sw" # swayNC panel
              "$mainMod, G, exec, ${../module-config/scripts/rofi.sh} games" # game launcher
              "$mainMod ALT, G, exec, ${../module-config/scripts/gamemode.sh}" # disable hypr effects for gamemode
              "$mainMod, V, exec, ${../module-config/scripts/ClipManager.sh}" # Clipboard Manager
              "$mainMod, M, exec, pkill -x rofi || ${../module-config/scripts/rofimusic.sh}" # online music

              # Screenshot/Screencapture
              "$mainMod CTRL, P, exec, ${../module-config/scripts/screenshot.sh} s" # drag to snip an area / click on a window to /* print */ it
              "$mainMod, P, exec, ${../module-config/scripts/screenshot.sh} sf" # frozen screen, drag to snip an area / click on a window to print it
              "$mainMod, print, exec, ${../module-config/scripts/screenshot.sh} m" # print focused monitor
              "$mainMod ALT, P, exec, ${../module-config/scripts/screenshot.sh} p" # print all monitor outputs
              "CTRL ALT, A, exec, ${../module-config/scripts/screenshot-annotate.sh}" # screenshot + annotate workflow

              # Functional keybinds
              ",xf86Sleep, exec, systemctl suspend" # Put computer into sleep mode
              ",XF86AudioMicMute,exec,swayosd-client --input-volume mute-toggle" # mute mic
              ",XF86AudioMute,exec,swayosd-client --output-volume mute-toggle" # mute audio
              ",XF86AudioPlay,exec,swayosd-client --player-status play-pause" # Play/Pause media with OSD
              ",XF86AudioPause,exec,swayosd-client --player-status play-pause" # Play/Pause media with OSD
              ",xf86AudioNext,exec,swayosd-client --player-status next" # go to next media with OSD
              ",xf86AudioPrev,exec,swayosd-client --player-status previous" # go to previous media with OSD

              # Keyboard lock indicators with OSD
              ",Caps_Lock,exec,swayosd-client --caps-lock" # Show Caps Lock status
              ",Num_Lock,exec,swayosd-client --num-lock" # Show Num Lock status

              # Custom system monitoring with swayosd
              "$mainMod, F1, exec, ${swayosd-custom} battery" # Show battery level
              "$mainMod, F2, exec, ${swayosd-custom} memory-usage" # Show memory usage
              "$mainMod, F3, exec, ${swayosd-custom} cpu-temp" # Show CPU temperature
              "$mainMod, F4, exec, ${swayosd-custom} disk-usage" # Show disk usage
              "$mainMod SHIFT, F1, exec, ${swayosd-custom} microphone-volume" # Show mic volume
              "$mainMod SHIFT, F2, exec, ${swayosd-custom} wifi-strength" # Show WiFi strength

              # Media key mappings (default behavior - icons on keys)
              # F6 icon (person head + sound waves) - Works natively, no binding needed
              # F7 icon (happy face) - Works natively for window selector, no binding needed
              # F8 icon (screenshot) - Screenshot function
              ",Print,exec,bash -c '${../module-config/scripts/screenshot.sh} s && ${swayosd-custom} screenshot-taken'" # F8 icon: Screenshot with OSD feedback
              # F10 icon (search) - Search/launcher function
              ",XF86Search,exec,bash -c 'pkill rofi || rofi -show run && ${swayosd-custom} launcher-opened'" # F10 icon: Search/launcher with OSD feedback

              # ",xf86AudioNext,exec,${../module-config/scripts/MediaCtrl.sh} next" # go to next media
              # ",xf86AudioPrev,exec,${../module-config/scripts/MediaCtrl.sh} previous" # go to previous media
              # ",XF86AudioPlay,exec,${../module-config/scripts/MediaCtrl.sh} play-pause" # go to next media
              # ",XF86AudioPause,exec,${../module-config/scripts/MediaCtrl.sh} play-pause" # go to next media

              # to switch between windows in a floating workspace
              "$mainMod, Tab, cyclenext"
              "$mainMod, Tab, bringactivetotop"

              # Switch workspaces relative to the active workspace with mainMod + CTRL + [←→]
              "$mainMod CTRL, right, workspace, r+1"
              "$mainMod CTRL, left, workspace, r-1"

              # move to the first empty workspace instantly with mainMod + CTRL + [↓]
              "$mainMod CTRL, down, workspace, empty"

              # Move focus with mainMod + arrow keys
              "$mainMod, left, movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up, movefocus, u"
              "$mainMod, down, movefocus, d"
              "ALT, Tab, movefocus, d"

              # Move focus with mainMod + HJKL keys (vim style)
              "$mainMod, h, movefocus, l"
              "$mainMod, j, movefocus, d"
              "$mainMod, k, movefocus, u"
              "$mainMod, l, movefocus, r"

              # Go to workspace 6 and 7 with mouse side buttons
              "$mainMod, mouse:276, workspace, 5"
              "$mainMod, mouse:275, workspace, 6"
              "$mainMod SHIFT, mouse:276, movetoworkspace, 5"
              "$mainMod SHIFT, mouse:275, movetoworkspace, 6"
              "$mainMod CTRL, mouse:276, movetoworkspacesilent, 5"
              "$mainMod CTRL, mouse:275, movetoworkspacesilent, 6"

              # Rebuild NixOS with a KeyBind
              "$mainMod, U, exec, $term -e ${../module-config/scripts/rebuild.sh}"

              # Split window horizontal (next window opens to the right)
              "$mainMod ALT, h, layoutmsg, preselect r"
              # Split window vertical (next window opens below)
              "$mainMod ALT, v, layoutmsg, preselect d"

              # Scroll through existing workspaces with mainMod + scroll
              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up, workspace, e-1"

              # Move active window to a relative workspace with mainMod + CTRL + ALT + [←→]
              "$mainMod CTRL ALT, right, movetoworkspace, r+1"
              "$mainMod CTRL ALT, left, movetoworkspace, r-1"

              # Move active window around current workspace with mainMod + SHIFT [←→↑↓]
              "$mainMod SHIFT, left, movewindow, l"
              "$mainMod SHIFT, right, movewindow, r"
              "$mainMod SHIFT, up, movewindow, u"
              "$mainMod SHIFT, down, movewindow, d"

              # Move active window around current workspace with mainMod + SHIFT [HLJK] (shorter)
              "$mainMod SHIFT, H, movewindow, l"
              "$mainMod SHIFT, L, movewindow, r"
              "$mainMod SHIFT, K, movewindow, u"
              "$mainMod SHIFT, J, movewindow, d"

              # Swap windows with mainMod + SHIFT + CTRL [HLJK] (longer for less common action)
              "$mainMod SHIFT $CONTROL, H, swapwindow, l"
              "$mainMod SHIFT $CONTROL, L, swapwindow, r"
              "$mainMod SHIFT $CONTROL, K, swapwindow, u"
              "$mainMod SHIFT $CONTROL, J, swapwindow, d"

              # Swap windows with mainMod + SHIFT + CTRL [arrows] (longer for less common action)
              "$mainMod SHIFT $CONTROL, left, swapwindow, l"
              "$mainMod SHIFT $CONTROL, right, swapwindow, r"
              "$mainMod SHIFT $CONTROL, up, swapwindow, u"
              "$mainMod SHIFT $CONTROL, down, swapwindow, d"

              # Split toggles (preselect for next window only)
              "$mainMod, semicolon, layoutmsg, preselect r" # split horizontally (next window right)
              "$mainMod, apostrophe, layoutmsg, preselect d" # split vertically (next window below)

              # Toggle split direction of current window
              "$mainMod, O, togglesplit" # Toggle split direction of focused window

              # Enter resize mode
              "$mainMod, R, exec, notify-send '↔ Resize Mode' 'h/l=width, k/j=height, ESC/Enter=Exit' -u normal -t 8000 -i view-fullscreen --skip-summary"
              "$mainMod, R, submap, ↔ resize" # Enter resize mode

              # Special workspaces submap - follows existing submap pattern
              # Template for adding new special workspaces:
              # 1. Add window rule: "workspace special:[name], class:^([AppClass])$"
              # 2. Add to notification: update letters in notification
              # 3. Add to submap: bind = , [letter], exec, notify-send + togglespecialworkspace + submap reset
              "$mainMod, S, exec, notify-send ' Special Workspaces' 's=Scratch, m=Music, p=Password, ESC/Enter=Exit' -u normal -t 8000 -i applications-multimedia --skip-summary"
              "$mainMod, S, submap,  special"
              "$mainMod SHIFT, S, movetoworkspace, special"  # Move current window to default scratchpad
            ]
            ++ (builtins.concatLists (
              builtins.genList (
                x:
                let
                  ws =
                    let
                      c = (x + 1) / 10;
                    in
                    builtins.toString (x + 1 - (c * 10));
                in
                [
                  "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
                  "$mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                  "$mainMod CTRL, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
                ]
              ) 10
            ));
          bindm = [
            # Move/Resize windows with mainMod + LMB/RMB and dragging
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
        };
        extraConfig = ''
          binds {
            workspace_back_and_forth = 1
            #allow_workspace_cycles=1
            #pass_mouse_when_bound=0
          }

          # Submap for exploring directories
          submap = 󰉋 Explore
          bind = , d, exec, nautilus ~/Downloads
          bind = , d, submap, reset
          bind = , o, exec, nautilus ~/Documents
          bind = , o, submap, reset
          bind = , v, exec, nautilus ~/dev
          bind = , v, submap, reset
          bind = , s, exec, nautilus ~/Pictures/Screenshots
          bind = , s, submap, reset
          bind = , n, exec, nautilus ~/dev/nix/nixcfg
          bind = , n, submap, reset
          bind = , escape, submap, reset
          bind = , return, submap, reset

          # Special workspaces submap
          submap =  special
          bind = , s, exec, notify-send '📋 Scratchpad' 'Toggling default scratchpad' -u low -t 2000 -i applications-utilities --skip-summary
          bind = , s, togglespecialworkspace,
          bind = , s, submap, reset
          bind = , m, exec, notify-send '🎵 Music' 'Toggling Spotify workspace' -u low -t 2000 -i applications-multimedia --skip-summary
          bind = , m, togglespecialworkspace, spotify
          bind = , m, submap, reset
          bind = , p, exec, notify-send '🔐 1Password' 'Toggling 1Password workspace' -u low -t 2000 -i applications-security --skip-summary
          bind = , p, togglespecialworkspace, 1password
          bind = , p, submap, reset
          bind = , escape, submap, reset
          bind = , return, submap, reset
          submap = reset

          # Resize submap for cleaner resize workflow
          submap = ↔ resize
          binde = , h, resizeactive, -30 0
          binde = , l, resizeactive, 30 0
          binde = , k, resizeactive, 0 -30
          binde = , j, resizeactive, 0 30
          bind = , escape, submap, reset
          bind = , return, submap, reset
          submap = reset

          # Easily plug in any monitor
          monitor=,preferred,auto,1

          # 1080p-HDR monitor on the left, 4K-HDR monitor in the middle and 1080p vertical monitor on the right.
          # monitor=desc:BNQ BenQ EW277HDR 99J01861SL0,preferred,-1920x0,1
          # monitor=desc:BNQ BenQ EL2870U PCK00489SL0,preferred,0x0,2
          # monitor=desc:BNQ BenQ xl2420t 99D06760SL0,preferred,1920x0,1,transform,1 # 5 for fipped

          # Binds workspaces to my monitors only (find desc with: hyprctl monitors)
          # workspace=1,monitor:desc:BNQ BenQ EL2870U PCK00489SL0,default:true
          # workspace=2,monitor:desc:BNQ BenQ EL2870U PCK00489SL0
          # workspace=3,monitor:desc:BNQ BenQ EL2870U PCK00489SL0
          # workspace=4,monitor:desc:BNQ BenQ EL2870U PCK00489SL0
          # workspace=5,monitor:desc:BNQ BenQ EW277HDR 99J01861SL0,default:true
          # workspace=6,monitor:desc:BNQ BenQ EW277HDR 99J01861SL0
          # workspace=7,monitor:desc:BNQ BenQ EW277HDR 99J01861SL0
          # workspace=8,monitor:desc:BNQ BenQ xl2420t 99D06760SL0,default:true
          # workspace=9,monitor:desc:BNQ BenQ xl2420t 99D06760SL0
          # workspace=10,monitor:desc:BNQ BenQ EL2870U PCK00489SL0

          # Standard workspace assignments
          workspace=1,monitor:,default:true
          workspace=2,monitor:
          workspace=3,monitor:
          workspace=4,monitor:
          workspace=5,monitor:
          workspace=6,monitor:
          workspace=7,monitor:
          workspace=8,monitor:
          workspace=9,monitor:
          workspace=10,monitor:

          # Special workspace on all monitors
          workspace=special,monitor:
        '';
      };

      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };

    };
  };
}
