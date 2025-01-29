{ user-settings, lib, config, pkgs, inputs, ... }:
let cfg = config.desktops.gnome.extensions;
in {

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
      gnomeExtensions.gsconnect
      gnomeExtensions.vscode-search-provider
      gnomeExtensions.vscode-workspaces-gnome
      gnomeExtensions.window-calls
      gnomeExtensions.quick-settings-audio-panel
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.caffeine
      gnomeExtensions.media-controls
      pulseaudio # pactl needed for gnomeExtensions.quick-settings-audio-panel
    ];

    home-manager.users."${user-settings.user.username}" = {
      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {
        "org/gnome/shell" = {
          # Enabled extensions
          enabled-extensions = [
            "tilingshell@ferrarodomenico.com"
            "caffeine@patapon.info"
            "quick-settings-audio-panel@rayzeq.github.io"
            "bluetooth-quick-connect@bjarosze.gmail.com"
            "mediacontrols@cliffniff.github.com"
            "vscode-search-provider@mrmarble.github.com"
          ];

          # Disabled extensions
          disabled-extensions = [
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
            "gsconnect@andyholmes.github.io"
            "window-calls@domandoman.xyz"

          ];
        };

        "org/gnome/shell/extensions/mediacontrols" = {
          extension-position = "Right";
          label-width = mkUint32 0;
          mediacontrols-show-popup-menu = [ "<Shift><Control><Alt>m" ];
        };

        "org/gnome/shell/extensions/tilingshell" = {
          enable-blur-selected-tilepreview = true;
          enable-blur-snap-assistant = true;
          inner-gaps = mkUint32 16;
          last-version-name-installed = "15.1";
          layouts-json = ''
            [{"id":"Layout 1","tiles":[{"x":0,"y":0,"width":0.22,"height":0.5,"groups":[1,2]},{"x":0,"y":0.5,"width":0.22,"height":0.5,"groups":[1,2]},{"x":0.22,"y":0,"width":0.56,"height":1,"groups":[2,3]},{"x":0.78,"y":0,"width":0.22,"height":0.5,"groups":[3,4]},{"x":0.78,"y":0.5,"width":0.22,"height":0.5,"groups":[3,4]}]},{"id":"Layout 2","tiles":[{"x":0,"y":0,"width":0.22,"height":1,"groups":[1]},{"x":0.22,"y":0,"width":0.56,"height":1,"groups":[1,2]},{"x":0.78,"y":0,"width":0.22,"height":1,"groups":[2]}]},{"id":"Layout 3","tiles":[{"x":0,"y":0,"width":0.33,"height":1,"groups":[1]},{"x":0.33,"y":0,"width":0.67,"height":1,"groups":[1]}]},{"id":"Layout 4","tiles":[{"x":0,"y":0,"width":0.67,"height":1,"groups":[1]},{"x":0.67,"y":0,"width":0.33,"height":1,"groups":[1]}]},{"id":"3722439","tiles":[{"x":0,"y":0,"width":0.35358796296296297,"height":0.49234449760765553,"groups":[1,2]},{"x":0.35358796296296297,"y":0,"width":0.6464120370370365,"height":1,"groups":[1]},{"x":0,"y":0.49234449760765553,"width":0.35358796296296297,"height":0.5076555023923448,"groups":[2,1]}]},{"id":"880357","tiles":[{"x":0,"y":0,"width":0.2502906976744186,"height":1,"groups":[2]},{"x":0.5002906976744186,"y":0,"width":0.24970930232558142,"height":1,"groups":[3,1]},{"x":0.2502906976744186,"y":0,"width":0.25,"height":1,"groups":[1,2]},{"x":0.75,"y":0,"width":0.25,"height":1,"groups":[3]}]},{"id":"942750","tiles":[{"x":0,"y":0,"width":0.3,"height":1,"groups":[1]},{"x":0.3,"y":0,"width":0.3511627906976745,"height":1,"groups":[2,1]},{"x":0.6511627906976745,"y":0,"width":0.3488372093023255,"height":1,"groups":[2]}]},{"id":"26976321","tiles":[{"x":0,"y":0,"width":0.20813953488372092,"height":1,"groups":[1]},{"x":0.20813953488372092,"y":0,"width":0.5627906976744186,"height":0.7800711743772242,"groups":[2,3,1]},{"x":0.7709302325581395,"y":0,"width":0.22906976744186042,"height":1,"groups":[2]},{"x":0.20813953488372092,"y":0.7800711743772242,"width":0.5627906976744186,"height":0.21992882562277583,"groups":[3,2,1]}]}]'';
          outer-gaps = mkUint32 8;
          overridden-settings = ''
            {"org.gnome.mutter.keybindings":{"toggle-tiled-right":"['<Super>Right']","toggle-tiled-left":"['<Super>Left']"},"org.gnome.desktop.wm.keybindings":{"maximize":"['<Super>Up']","unmaximize":"['<Super>Down', '<Alt>F5']"},"org.gnome.mutter":{"edge-tiling":"false"}}'';
          quarter-tiling-threshold = mkUint32 41;
          selected-layouts =
            [ [ "Layout 1" ] [ "Layout 1" ] [ "Layout 1" ] [ "Layout 1" ] ];
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
        };

      };

    };

  };
}
