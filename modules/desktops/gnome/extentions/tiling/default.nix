{
  user-settings,
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.desktops.gnome.extensions.tiling;
in
{

  options = {
    desktops.gnome.extensions.tiling.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable desktops.gnome.extensions.tiling.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      gnomeExtensions.forge
      gnomeExtensions.space-bar
      zenity
    ];

    home-manager.users."${user-settings.user.username}" = {
      home.file.".config/forge/stylesheet/forge/stylesheet.css".text = let
        colors = config.lib.stylix.colors;
      in ''
        .tiled {
          color: #${colors.base08};
          opacity: 1;
          border-width: 3px;
        }

        .split {
          color: #${colors.base0A};
          opacity: 1;
          border-width: 3px;
        }

        .stacked {
          color: #${colors.base09};
          opacity: 1;
          border-width: 3px;
        }

        .tabbed {
          color: #${colors.base0C};
          opacity: 1;
          border-width: 3px;
        }

        .floated {
          color: #${colors.base0E};
          border-width: 3px;
          opacity: 1;
        }

        .window-tiled-border {
          border-width: 3px;
          border-color: #${colors.base08};
          border-style: solid;
          border-radius: 14px;
        }

        .window-split-border {
          border-width: 3px;
          border-color: #${colors.base0A};
          border-style: solid;
          border-radius: 14px;
        }

        .window-split-horizontal {
          border-left-width: 0;
          border-top-width: 0;
          border-bottom-width: 0;
        }

        .window-split-vertical {
          border-left-width: 0;
          border-top-width: 0;
          border-right-width: 0;
        }

        .window-stacked-border {
          border-width: 3px;
          border-color: #${colors.base09};
          border-style: solid;
          border-radius: 14px;
        }

        .window-tabbed-border {
          border-width: 3px;
          border-color: #${colors.base0C};
          border-style: solid;
          border-radius: 14px;
        }

        .window-tabbed-bg {
          border-radius: 8px;
        }

        .window-tabbed-tab {
          background-color: #${colors.base01};
          border-color: #${colors.base0C}99;
          border-width: 1px;
          border-radius: 8px;
          color: #${colors.base05};
          margin: 1px;
          box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.2);
        }

        .window-tabbed-tab-active {
          background-color: #${colors.base0C};
          color: #${colors.base00};
          box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.2);
        }

        .window-tabbed-tab-close {
          padding: 3px;
          margin: 4px;
          border-radius: 16px;
          width: 16px;
          background-color: #${colors.base08};
        }

        .window-tabbed-tab-icon {
          margin: 3px;
        }

        .window-floated-border {
          border-width: 3px;
          border-color: #${colors.base0E};
          border-style: solid;
          border-radius: 14px;
        }

        .window-tilepreview-tiled {
          border-width: 1px;
          border-color: #${colors.base08}66;
          border-style: solid;
          border-radius: 14px;
          background-color: #${colors.base08}4D;
        }

        .window-tilepreview-stacked {
          border-width: 1px;
          border-color: #${colors.base09}66;
          border-style: solid;
          border-radius: 14px;
          background-color: #${colors.base09}4D;
        }

        .window-tilepreview-swap {
          border-width: 1px;
          border-color: #${colors.base0B}66;
          border-style: solid;
          border-radius: 14px;
          background-color: #${colors.base0B}66;
        }

        .window-tilepreview-tabbed {
          border-width: 1px;
          border-color: #${colors.base0C}66;
          border-style: solid;
          border-radius: 14px;
          background-color: #${colors.base0C}4D;
        }
      '';

      home.file.".config/forge/config/windows.json".text = ''
        {
            "overrides": [
                {
                    "wmClass": "org.gnome.Shell.Extensions",
                    "wmTitle": "Forge Settings",
                    "mode": "float"
                },
                {
                    "wmClass": "jetbrains-toolbox",
                    "mode": "float"
                },
                {
                    "wmClass": "jetbrains-goland",
                    "wmTitle": "splash",
                    "mode": "float"
                },
                {
                    "wmClass": "jetbrains-webstorm",
                    "wmTitle": "splash",
                    "mode": "float"
                },
                {
                    "wmClass": "jetbrains-phpstorm",
                    "wmTitle": "splash",
                    "mode": "float"
                },
                {
                    "wmClass": "jetbrains-datagrip",
                    "wmTitle": "splash",
                    "mode": "float"
                },
                {
                    "wmClass": "jetbrains-rubymine",
                    "wmTitle": "splash",
                    "mode": "float"
                },
                {
                    "wmClass": "jetbrains-idea",
                    "wmTitle": "splash",
                    "mode": "float"
                },
                {
                    "wmClass": "Com.github.amezin.ddterm",
                    "mode": "float"
                },
                {
                    "wmClass": "Com.github.donadigo.eddy",
                    "mode": "float"
                },
                {
                    "wmClass": "Conky",
                    "mode": "float"
                },
                {
                    "wmClass": "Gnome-initial-setup",
                    "mode": "float"
                },
                {
                    "wmClass": "org.gnome.Calculator",
                    "mode": "float"
                },
                {
                    "wmClass": "gnome-terminal-server",
                    "wmTitle": "Preferences – General",
                    "mode": "float"
                },
                {
                    "wmClass": "gnome-terminal-preferences",
                    "mode": "float"
                },
                {
                    "wmClass": "Guake",
                    "mode": "float"
                },
                {
                    "wmClass": "zoom",
                    "mode": "float"
                },
                {
                    "wmClass": "firefox",
                    "wmTitle": "About Mozilla Firefox",
                    "mode": "float"
                },
                {
                    "wmClass": "firefox",
                    "wmTitle": "!Mozilla Firefox",
                    "mode": "float"
                },
                {
                    "wmClass": "org.mozilla.firefox.desktop",
                    "wmTitle": "About Mozilla Firefox",
                    "mode": "float"
                },
                {
                    "wmClass": "org.mozilla.firefox.desktop",
                    "wmTitle": "!Mozilla Firefox",
                    "mode": "float"
                },
                {
                    "wmClass": "thunderbird",
                    "wmTitle": "About Mozilla Thunderbird",
                    "mode": "float"
                },
                {
                    "wmClass": "thunderbird",
                    "wmTitle": "!Mozilla Thunderbird",
                    "mode": "float"
                },
                {
                    "wmClass": "org.mozilla.Thunderbird.desktop",
                    "wmTitle": "About Mozilla Thunderbird",
                    "mode": "float"
                },
                {
                    "wmClass": "org.mozilla.Thunderbird.desktop",
                    "wmTitle": "!Mozilla Thunderbird",
                    "mode": "float"
                },
                {
                    "wmClass": "evolution-alarm-notify",
                    "mode": "float"
                },
                {
                    "wmClass": "variety",
                    "mode": "float"
                },
                {
                    "wmClass": "update-manager",
                    "mode": "float"
                }
            ]
        }
      '';

      home.file.".local/bin/show-forge-shortcuts".text = ''
        #!/usr/bin/env bash
        zenity --info --width=800 --height=600 --title="Forge Keyboard Shortcuts" --text="
        <b>Window Focus</b>
        Super+h/j/k/l    Focus left/down/up/right

        <b>Window Movement</b>
        Super+Shift+h/j/k/l    Move window left/down/up/right

        <b>Window Swapping</b>
        Super+Ctrl+h/j/k/l     Swap window left/down/up/right
        Super+Return           Swap with last active window

        <b>Window Resizing</b>
        Super+Ctrl+y/u/i/o     Resize left/bottom/top/right increase
        Super+Shift+Ctrl+y/u/i/o    Resize left/bottom/top/right decrease

        <b>Window Layouts</b>
        Super+g              Toggle split layout
        Super+v              Split vertical
        Super+z              Split horizontal
        Super+Shift+s        Toggle stacked layout
        Super+Shift+t        Toggle tabbed layout

        <b>Window States</b>
        Super+c              Toggle float
        Super+Shift+c        Toggle always float

        <b>Window Snapping</b>
        Ctrl+Alt+c           Snap center
        Ctrl+Alt+d/g         Snap 1/3 left/right
        Ctrl+Alt+e/t         Snap 2/3 left/right

        <b>Gaps & Settings</b>
        Super+Ctrl+plus/minus    Increase/decrease gaps
        Super+x              Toggle focus border
        Super+w              Toggle tiling
        Super+Shift+w        Toggle workspace tiling

        <b>Workspaces</b>
        Super+1-9,0          Switch to workspace 1-10
        Super+Shift+1-9,0    Move window to workspace 1-10

        <b>Other</b>
        Ctrl+Alt+y           Toggle tab decoration
        "
      '';

      home.file.".local/bin/show-forge-shortcuts".executable = true;

      dconf.settings = with inputs.home-manager.lib.hm.gvariant; {
        # Non-keybinding configurations
        "org/gnome/shell/extensions/forge" = {
          dnd-center-layout = "swap";
        };

        "org/gnome/shell/extensions/space-bar/behavior" = {
          indicator-style = "workspaces-bar";
          always-show-numbers = true;
          show-empty-workspaces = false;
        };

        "org/gnome/shell/extensions/space-bar/shortcuts" = {
          enable-move-to-workspace-shortcuts = true;
        };

        "org/gnome/mutter" = {
          dynamic-workspaces = false;
        };

        "org/gnome/desktop/wm/preferences" = {
          num-workspaces = mkUint32 10;
        };

        "org/gnome/desktop/wm/keybindings" = {
          move-to-workspace-10 = [ "<Super><Shift>0" ];
          switch-to-workspace-10 = [ "<Super>0" ];
        };
      };
    };

  };
}