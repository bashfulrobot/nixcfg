{
  user-settings,
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.apps.nautilus;

  # Nautilus script packages using standard pattern
  nautilusScripts = with pkgs; [
    (writeShellScriptBin "copy-path" (builtins.readFile ./scripts/copy-path.sh))
  ];

in
{
  options = {
    apps.nautilus.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Nautilus file manager with custom scripts and preferences.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install Nautilus and related packages
    # Note: This moves nautilus and nautilus-open-any-terminal from hyprland module
    environment.systemPackages =
      with pkgs;
      [
        # keep-sorted start case=no numeric=yes
        code-nautilus
        glib # for gsettings
        adwaita-icon-theme
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-libav
        gvfs # for trash, mount, and other functionality
        libheif
        libnotify # for notify-send (already in hyprland but consolidating here)
        nautilus
        nautilus-open-any-terminal # open terminal(s) in nautilus
        sushi # quick preview for nautilus
        wl-clipboard # for Wayland clipboard support
        xclip # Fallback for X11 clipboard support
        # keep-sorted end
      ]
      ++ nautilusScripts;

    # Configure Nautilus scripts and preferences
    home-manager.users."${user-settings.user.username}" = {
      home.file = {
        # Create Nautilus scripts directory and copy scripts
        ".local/share/nautilus/scripts/copy-path" = {
          source = ./scripts/copy-path.sh;
          executable = true;
        };
      };

      # Nautilus preferences via dconf
      dconf.settings = {
        "org/gnome/nautilus/preferences" = {
          # Default view mode
          "default-folder-viewer" = "icon-view";
          # Show hidden files
          "show-hidden-files" = false;
          # Show delete permanently option
          "show-delete-permanently" = true;
          # Show create symbolic link option
          "show-create-link" = true;
          # Sort directories first
          "sort-directories-first" = true;
        };

        "org/gnome/nautilus/icon-view" = {
          # Default zoom level
          "default-zoom-level" = "large";
        };

        "org/gnome/nautilus/list-view" = {
          # Default zoom level for list view
          "default-zoom-level" = "small";
        };
      };
    };

    # Enable necessary services
    services = {
      gnome.sushi = {
        enable = true; # Quick file previewer
      };
    };
  };
}
