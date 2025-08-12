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

  terminal = "alacritty";
  terminalFileManager = "ranger";
  browser = getExe pkgs.chromium;
  kbdLayout = "us"; # US layout
  kbdVariant = ""; # Standard US variant
in
{

  imports = [
    ../module-config/programs/waybar
    ../module-config/programs/wlogout
    ../module-config/programs/rofi
    ../module-config/programs/hypridle
    ../module-config/programs/hyprlock
    ../module-config/programs/swaync
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

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    systemd.user.services.hyprpolkitagent = {
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
    services = {
      displayManager.defaultSession = "hyprland";
      xserver = {
        enable = true;
        displayManager = {
          # sddm = {
          #   enable = true;
          #   wayland.enable = true;
          # };
          gdm = {
            enable = true;
            wayland = true;
          };
        };
      };
      gnome.gnome-keyring.enable = true;
      blueman.enable = true;
    };

    programs.hyprland = {
      enable = true;
      # withUWSM = true;
    };

    environment.systemPackages = with pkgs; [
      hyprpaper
      hyprpicker
      cliphist
      grimblast
      swappy
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
      libsecret
      blueman
      papirus-folders
      # socat # for and autowaybar.sh
      # jq # for and autowaybar.sh
    ];

    # security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.gdm.enableGnomeKeyring = true;

    hw.bluetooth.enable = true;

    sys = {
      dconf.enable = true;
      stylix-theme.enable = true;
      xdg.enable = true;
    };

    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };

    ##### Home Manager Config options #####
    home-manager.users."${user-settings.user.username}" = {

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
            "GNOME_KEYRING_CONTROL,$XDG_RUNTIME_DIR/keyring"
            # Additional theming variables for comprehensive dark mode support
            "GTK_THEME,Adwaita:dark"
            "QT_STYLE_OVERRIDE,kvantum"
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

            "waybar"
            "swaync"
            "nm-applet --indicator"
            "wl-clipboard-history -t"
            "${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch cliphist store" # clipboard store text data
            "${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch cliphist store" # clipboard store image data
            "rm '$XDG_CACHE_HOME/cliphist/db'" # Clear clipboard
            "${../module-config/scripts/batterynotify.sh}" # battery notification
            # "${../module-config/scripts/autowaybar.sh}" # uncomment packages at the top
            "polkit-agent-helper-1"
            # "gnome-keyring-daemon --start --components=secrets,ssh,pkcs11" # Now handled by GDM/systemd
            "pamixer --set-volume 50"
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
            "col.inactive_border" = lib.mkDefault "rgba(b4befecc) rgba(6c7086cc) 45deg";
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

            "blur, swaync-control-center"
            "blur, swaync-notification-window"
            "ignorezero, swaync-control-center"
            "ignorezero, swaync-notification-window"
            "ignorealpha 0.7, swaync-control-center"
            # "ignorealpha 0.8, swaync-notification-window"
            # "dimaround, swaync-control-center"
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
            explicit_sync = 2; # 0 = off, 1 = on, 2 = auto based on gpu driver.
            explicit_sync_kms = 2; # 0 = off, 1 = on, 2 = auto based on gpu driver.
            direct_scanout = 2; # 0 = off, 1 = on, 2 = auto (on with content type ‘game’)
          };
          misc = {
            disable_hyprland_logo = true;
            mouse_move_focuses_monitor = true;
            swallow_regex = "^(Alacritty|kitty)$";
            enable_swallow = true;
            vfr = true; # always keep on
            vrr = 1; # enable variable refresh rate (0=off, 1=on, 2=fullscreen only)
          };
          xwayland.force_zero_scaling = false;
          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 3;
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
            permanent_direction_override = false;
            smart_split = true;
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
            # "workspace 6, class:^(Spotify)$"
            # "workspace 6, title:(.*)(Spotify)(.*)$"

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

            # Resize windows with hjkl keys
            "$mainMod SHIFT, l, resizeactive, 30 0"
            "$mainMod SHIFT, h, resizeactive, -30 0"
            "$mainMod SHIFT, k, resizeactive, 0 -30"
            "$mainMod SHIFT, j, resizeactive, 0 30"

            # Functional keybinds
            ",XF86MonBrightnessDown,exec,brightnessctl set 2%-"
            ",XF86MonBrightnessUp,exec,brightnessctl set +2%"
            ",XF86AudioLowerVolume,exec,pamixer -d 2"
            ",XF86AudioRaiseVolume,exec,pamixer -i 2"
          ];
          bind =
            let
              autoclicker = pkgs.callPackage ../module-config/scripts/autoclicker.nix { };
            in
            [
              # Keybinds help menu
              "$mainMod, question, exec, ${../module-config/scripts/keybinds.sh}"
              "$mainMod, slash, exec, ${../module-config/scripts/keybinds.sh}"
              "$mainMod CTRL, K, exec, ${../module-config/scripts/keybinds.sh}"

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
              "$mainMod, E, exec, $fileManager"
              "$mainMod, C, exec, $editor"
              "$mainMod, F, exec, $browser"
              "$mainMod SHIFT, S, exec, spotify"
              "$mainMod SHIFT, Y, exec, youtube-music"
              "$CONTROL ALT, DELETE, exec, $term -e '${getExe pkgs.btop}'" # System Monitor
              "$mainMod CTRL, C, exec, hyprpicker --autocopy --format=hex" # Colour Picker

              "$mainMod, A, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} drun" # launch desktop applications
              "$mainMod, SPACE, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} drun" # launch desktop applications
              "$mainMod, Z, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} emoji" # launch emoji picker
              # "$mainMod, tab, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} window" # switch between desktop applications
              # "$mainMod, R, exec, pkill -x rofi || ${../module-config/scripts/rofi.sh} file" # brrwse system files
              "$mainMod ALT, K, exec, ${../module-config/scripts/keyboardswitch.sh}" # change keyboard layout
              "$mainMod ALT, B, exec, blueman-manager" # bluetooth manager
              "$mainMod SHIFT, N, exec, swaync-client -t -sw" # swayNC panel
              "$mainMod SHIFT, Q, exec, swaync-client -t -sw" # swayNC panel
              "$mainMod, G, exec, ${../module-config/scripts/rofi.sh} games" # game launcher
              "$mainMod ALT, G, exec, ${../module-config/scripts/gamemode.sh}" # disable hypr effects for gamemode
              "$mainMod, V, exec, ${../module-config/scripts/ClipManager.sh}" # Clipboard Manager
              "$mainMod, M, exec, pkill -x rofi || ${../module-config/scripts/rofimusic.sh}" # online music

              # Screenshot/Screencapture
              "$mainMod, P, exec, ${../module-config/scripts/screenshot.sh} s" # drag to snip an area / click on a window to print it
              "$mainMod CTRL, P, exec, ${../module-config/scripts/screenshot.sh} sf" # frozen screen, drag to snip an area / click on a window to print it
              "$mainMod, print, exec, ${../module-config/scripts/screenshot.sh} m" # print focused monitor
              "$mainMod ALT, P, exec, ${../module-config/scripts/screenshot.sh} p" # print all monitor outputs

              # Functional keybinds
              ",xf86Sleep, exec, systemctl suspend" # Put computer into sleep mode
              ",XF86AudioMicMute,exec,pamixer --default-source -t" # mute mic
              ",XF86AudioMute,exec,pamixer -t" # mute audio
              ",XF86AudioPlay,exec,playerctl play-pause" # Play/Pause media
              ",XF86AudioPause,exec,playerctl play-pause" # Play/Pause media
              ",xf86AudioNext,exec,playerctl next" # go to next media
              ",xf86AudioPrev,exec,playerctl previous" # go to previous media

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

              # Move focus with mainMod + HJKL keys
              "$mainMod, h, movefocus, l"
              "$mainMod, l, movefocus, r"
              "$mainMod, k, movefocus, u"
              "$mainMod, j, movefocus, d"

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

              # Move active window around current workspace with mainMod + SHIFT + CTRL [←→↑↓]
              "$mainMod SHIFT $CONTROL, left, movewindow, l"
              "$mainMod SHIFT $CONTROL, right, movewindow, r"
              "$mainMod SHIFT $CONTROL, up, movewindow, u"
              "$mainMod SHIFT $CONTROL, down, movewindow, d"

              # Move active window around current workspace with mainMod + SHIFT + CTRL [HLJK]
              "$mainMod SHIFT $CONTROL, H, movewindow, l"
              "$mainMod SHIFT $CONTROL, L, movewindow, r"
              "$mainMod SHIFT $CONTROL, K, movewindow, u"
              "$mainMod SHIFT $CONTROL, J, movewindow, d"

              # Special workspaces (scratchpad)
              "$mainMod CTRL, S, movetoworkspacesilent, special"
              "$mainMod ALT, S, movetoworkspacesilent, special"
              "$mainMod, S, togglespecialworkspace,"
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
