{
  user-settings,
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.desktops.gnome.extensions;

  # Local extension builds
  unite-shell = pkgs.callPackage ../build/unite-shell.nix {};
in
{

  options = {
    desktops.gnome.extensions.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable desktops.gnome.extensions.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      unstable.gnomeExtensions.tiling-shell
      gnomeExtensions.vscode-search-provider
      gnomeExtensions.window-calls
      gnomeExtensions.quick-settings-audio-panel
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.caffeine
      gnomeExtensions.media-controls
      gnomeExtensions.appindicator
      gnomeExtensions.user-themes
      gnomeExtensions.undecorate
      gnomeExtensions.hide-top-bar
      unstable.gnomeExtensions.rounded-window-corners-reborn
      unite-shell # Local build
      pulseaudio # pactl needed for gnomeExtensions.quick-settings-audio-panel
      xorg.xprop # Required by unite-shell
    ];

    home-manager.users."${user-settings.user.username}" = {
      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {

        "org/gnome/shell" = {
          # temp - tshoot
          disable-user-extensions = false;
          # Enabled extensions
          enabled-extensions = [
            "caffeine@patapon.info"
            "quick-settings-audio-panel@rayzeq.github.io"
            "bluetooth-quick-connect@bjarosze.gmail.com"
            "mediacontrols@cliffniff.github.com"
            "appindicatorsupport@rgcjonas.gmail.com"
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "tilingshell@ferrarodomenico.com"
            "hidetopbar@mathieu.bidon.ca"
            "undecorate@sun.wxg@gmail.com"
            "rounded-window-corners-reborn@yilozt"

          ];

          # Disabled extensions
          disabled-extensions = [
            "window-calls@domandoman.xyz"
            "unite@hardpixel.eu"
          ];
        };

        "org/gnome/shell/extensions/mediacontrols" = {
          extension-position = "Right";
          label-width = mkUint32 0;
          mediacontrols-show-popup-menu = [ "<Shift><Control><Alt>m" ];
        };

        "org/gnome/shell/extensions/hidetopbar" = {
         mouse-sensitive = true;
         keep-round-corners = true;
         enable-intellihide = false;
         enable-active-window = false;
        };


        "org/gnome/shell/extensions/unite" = {
          autofocus-windows = false;
          greyscale-tray-icons = true;
          hide-window-titlebars = "maximized";
          notifications-position = "center";
          reduce-panel-spacing = false;
          show-appmenu-button = false;
          show-desktop-name = false;
          show-legacy-tray = true;
          show-window-buttons = "never";
          show-window-title = "never";
          use-activities-text = false;
          extend-left-box = false;
        };

        "org/gnome/shell/extensions/tilingshell" = {
          enable-blur-selected-tilepreview = true;
          enable-blur-snap-assistant = true;
          inner-gaps = mkUint32 16;
          layouts-json = ''[{"id":"Layout 1","tiles":[{"x":0,"y":0,"width":0.22,"height":0.5,"groups":[2,1]},{"x":0,"y":0.5,"width":0.22,"height":0.5,"groups":[1,2]},{"x":0.22,"y":0,"width":0.2768023255813954,"height":0.501779359430605,"groups":[5,6,2]},{"x":0.78,"y":0,"width":0.22,"height":0.5,"groups":[4,3]},{"x":0.78,"y":0.5,"width":0.22,"height":0.5,"groups":[4,3]},{"x":0.49680232558139537,"y":0,"width":0.28319767441860466,"height":0.500355871886121,"groups":[3,7,5]},{"x":0.22,"y":0.501779359430605,"width":0.2768023255813954,"height":0.49822064056939497,"groups":[6,5,2]},{"x":0.49680232558139537,"y":0.500355871886121,"width":0.28319767441860466,"height":0.49964412811387904,"groups":[7,3,5]}]},{"id":"3722439","tiles":[{"x":0,"y":0,"width":0.35358796296296297,"height":0.49234449760765553,"groups":[1,2]},{"x":0.35358796296296297,"y":0,"width":0.6464120370370365,"height":1,"groups":[1]},{"x":0,"y":0.49234449760765553,"width":0.35358796296296297,"height":0.5076555023923448,"groups":[2,1]}]}]'';

          outer-gaps = mkUint32 8;
          overridden-settings = ''{"org.gnome.mutter.keybindings":{"toggle-tiled-right":"['<Super>Right']","toggle-tiled-left":"['<Super>Left']"},"org.gnome.desktop.wm.keybindings":{"maximize":"['<Super>Up']","unmaximize":"['<Super>Down', '<Alt>F5']"},"org.gnome.mutter":{"edge-tiling":"false"}}'';
          quarter-tiling-threshold = mkUint32 41;
          selected-layouts = [
            [ "Layout 1" ]
            [ "Layout 1" ]
          ];
          show-indicator = false;
          snap-assistant-threshold = 57;
          span-window-down = [ "<Control><Super>Down" ];
          span-window-left = [ "<Control><Super>Left" ];
          span-window-right = [ "<Control><Super>Right" ];
          span-window-up = [ "<Control><Super>Up" ];
          tiling-system-activation-key = [ "0" ];
          top-edge-maximize = true;
        };

        "org/gnome/shell/extensions/bluetooth-quick-connect" = {
          bluetooth-auto-power-on = true;
          refresh-button-on = true;
          show-battery-value-on = true;
        };

        "org/gnome/shell/extensions/caffeine" = {
          indicator-position-max = 2;
          nightlight-control = "always";
          screen-blank = "always";
        };
        "org/gnome/shell/extensions/quick-settings-audio-panel" = {
          always-show-input-slider = true;
          media-control = "move";
          merge-panel = true;
          add-button-applications-output-reset-to-default = true;
          always-show-input-volume-slider = true;
          create-profile-switcher = false;
          master-volume-sliders-show-current-device = true;

        };

        "org/gnome/shell/extensions/rounded-window-corners-reborn" = {
          enable-preferences-entry = true;
          settings-version = mkUint32 7;
          skip-libadwaita-app = true;
          tweak-kitty-terminal = true;
        };

      };

    };


  };
}
