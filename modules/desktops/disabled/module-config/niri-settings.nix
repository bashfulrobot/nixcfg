{
  user-settings,
  ...
}:
{

  home-manager.users."${user-settings.user.username}" = {

    home.file = {

      ".config/niri/config.kdl".text = ''
        spawn-at-startup "eww" "--force-wayland" "daemon"
        spawn-at-startup "swayosd-server"
        spawn-at-startup "swww-daemon"
        spawn-at-startup "swww" "img" "{{desktop.wallpaper}}"
        spawn-at-startup "xwayland-satellite"
        spawn-at-startup "swaync"
        spawn-at-startup "ironbar"

        environment {
            DISPLAY ":1"
        }

        input {
            keyboard {
                xkb {
                    layout "fr"
                }
            }

            touchpad {
                tap
                natural-scroll
            }

            mouse {
                middle-emulation
            }
        }

        layout {
            gaps 8
            struts {
                top 20
                bottom 20
            }

            center-focused-column "never"

            preset-column-widths {
                proportion 0.33333
                proportion 0.5
                proportion 0.66667
            }

            default-column-width { proportion 0.5; }
            focus-ring {
                width 2
                active-gradient from="{{base08}}" to="{{base0D}}" angle=80
            }
            shadow {
                on
                softness 30
                spread 5
                offset x=0 y=5
                draw-behind-window true
                color "#00000070"
                inactive-color "#00000054"
            }
        }

        prefer-no-csd
        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
        animations {}

        window-rule {
            match app-id="onagre"
            focus-ring {
                off
            }
            border {
                off
            }
            draw-border-with-background false
        }

        window-rule {
            geometry-corner-radius 9
            clip-to-geometry true
        }

        layer-rule {
            match namespace="swaync"
            match at-startup=true
            opacity 0.8
            shadow {
                on
                draw-behind-window true
            }
        }

        binds {
            Mod+Shift+Colon { show-hotkey-overlay; }
            Mod+Return { spawn "{{apps.term}}"; }
            Mod+G { spawn "{{apps.launcher}}"; }
            Mod+S { spawn "/code/onagre/target/release/./onagre"; }
            Mod+D { spawn {{apps.notifications}}; }

            XF86AudioRaiseVolume { spawn "swayosd-client" "--output-volume" "raise"; }
            XF86AudioLowerVolume { spawn "swayosd-client" "--output-volume" "lower"; }
            XF86AudioMute { spawn "swayosd-client" "--output-volume" "mute-toggle"; }
            XF86MonBrightnessUp { spawn "swayosd-client" "--brightness" "raise"; }
            XF86MonBrightnessDown { spawn "swayosd-client" "--brightness" "lower"; }

            Mod+Shift+A { close-window; }

            Mod+H     { focus-column-left; }
            Mod+J     { focus-window-or-workspace-down; }
            Mod+K     { focus-window-or-workspace-up; }
            Mod+L     { focus-column-right; }
            Mod+Shift+Space { toggle-window-floating; }

            Mod+Shift+H     { move-column-left; }
            Mod+Shift+J     { move-window-down; }
            Mod+Shift+K     { move-window-up; }
            Mod+Shift+L     { move-column-right; }

            Mod+Ctrl+H { focus-column-first; }
            Mod+Ctrl+L  { focus-column-last; }
            Mod+Ctrl+Shift+H { move-column-to-first; }
            Mod+Ctrl+Shift+L  { move-column-to-last; }

            Mod+Page_Down      { focus-workspace-down; }
            Mod+Page_Up        { focus-workspace-up; }
            Mod+U              { focus-workspace-down; }
            Mod+I              { focus-workspace-up; }
            Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
            Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
            Mod+Ctrl+U         { move-column-to-workspace-down; }
            Mod+Ctrl+I         { move-column-to-workspace-up; }

            Mod+Shift+Page_Down { move-workspace-down; }
            Mod+Shift+Page_Up   { move-workspace-up; }
            Mod+Shift+U         { move-workspace-down; }
            Mod+Shift+I         { move-workspace-up; }

            Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
            Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
            Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
            Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

            Mod+WheelScrollRight      { focus-column-right; }
            Mod+WheelScrollLeft       { focus-column-left; }
            Mod+Ctrl+WheelScrollRight { move-column-right; }
            Mod+Ctrl+WheelScrollLeft  { move-column-left; }

            Mod+Shift+WheelScrollDown      { focus-column-right; }
            Mod+Shift+WheelScrollUp        { focus-column-left; }
            Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
            Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

            Mod+ampersand { focus-workspace 1; }
            Mod+eacute { focus-workspace 2; }
            Mod+quotedbl { focus-workspace 3; }
            Mod+apostrophe { focus-workspace 4; }
            Mod+parenleft { focus-workspace 5; }
            Mod+minus { focus-workspace 6; }
            Mod+egrave { focus-workspace 7; }
            Mod+underscore { focus-workspace 8; }
            Mod+ccedilla { focus-workspace 9; }

            Mod+Shift+ampersand { move-window-to-workspace 1; }
            Mod+Shift+eacute { move-window-to-workspace 2; }
            Mod+Shift+quotedbl { move-window-to-workspace 3; }
            Mod+Shift+apostrophe { move-window-to-workspace 4; }
            Mod+Shift+parenleft { move-window-to-workspace 5; }
            Mod+Shift+minus { move-window-to-workspace 6; }
            Mod+Shift+egrave { move-window-to-workspace 7; }
            Mod+Shift+underscore { move-window-to-workspace 8; }
            Mod+Shift+ccedilla { move-window-to-workspace 9; }

            Mod+Tab { focus-workspace-previous; }

            Mod+Comma  { consume-or-expel-window-left; }
            Mod+SemiColon { consume-or-expel-window-right; }

            Mod+R { switch-preset-column-width; }
            Mod+F { maximize-column; }
            Mod+Shift+F { fullscreen-window; }
            Mod+C { center-column; }
            Mod+N { toggle-column-tabbed-display; }

            Mod+ParenRight { set-column-width "-10%"; }
            Mod+Equal { set-column-width "+10%"; }

            Mod+Shift+ParenRight { set-window-height "-10%"; }
            Mod+Shift+Equal { set-window-height "+10%"; }
            Print { screenshot; }
            Ctrl+Print { screenshot-screen; }
            Alt+Print { screenshot-window; }
            Mod+Shift+E { quit; }
            Mod+Shift+P { power-off-monitors; }
        }

      '';
    };
  };

}
