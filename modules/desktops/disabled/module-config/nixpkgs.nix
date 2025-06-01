{
  pkgs,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    alacritty
    wl-clipboard
    # networkmanagerapplet
    # blueman
    # Core components you spawn at startup
    eww                # Widget toolkit
    swayosd            # On-screen display for volume/brightness
    swww               # Wallpaper daemon
    swaync             # Notification center


    # Screenshot utilities
    grim               # Screenshot utility (used by Print key)
    slurp              # Area selection (used with grim)

    # Other utilities referenced
    xwayland-satellite # XWayland support
    onagre             # Application launcher (referenced in your config)

    # Command line tools used in your config
    util-linux         # For pkill and other utilities
    coreutils          # Basic utilities like sleep
  ];

}
