{
  lib,
  pkgs,
  config,
  ...
}:
let

  # Niri scripts
  niriScripts = import ./scripts.nix { inherit pkgs; };

  # Fonts for Niri environment
  niriFonts = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Essential packages for Niri environment
  niriPackages = with pkgs; [

    # Launcher/Menu
    bemoji

    # Status bar
    waybar

    # Notifications
    swaynotificationcenter
    libnotify

    # Screen management
    wl-clipboard
    grim
    slurp

    # Idle and lock
    hypridle
    swaylock

    # OSD
    swayosd

    # Authentication agent
    polkit_gnome

    # File manager
    nautilus

    # System tools
    pavucontrol
    brightnessctl
    blueman

    # Session management
    greetd.tuigreet

    # Required for scripts
    jq
  ];

in
{
  imports = [
    ./fuzzel
    ./waybar
    ./swaync
    ./hypridle
    ./cliphist
    ./swayosd
  ];

  environment.systemPackages = niriPackages ++ niriScripts ++ niriFonts;

  cli = {
    ghostty.enable = true;
  };

}
