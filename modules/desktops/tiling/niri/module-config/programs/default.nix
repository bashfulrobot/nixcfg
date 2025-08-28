{
  lib,
  pkgs,
  config,
  ...
}:
let

  # Niri scripts (imported from scripts/default.nix)
  niriScripts = import ../scripts pkgs;

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
    hyprpicker

    # Idle and lock
    hypridle
    swaylock
    hyprlock

    # OSD
    swayosd

    # Authentication agent
    polkit_gnome

    # File manager
    nautilus
    nemo

    # System tools
    pavucontrol
    brightnessctl
    blueman
    
    # Media controls
    playerctl
    pulseaudio  # for pactl

    # Session management
    greetd.tuigreet

    # Required for scripts
    jq
    
    # AI chat (if available) - assuming it's declared elsewhere
    # alpaca / com.jeffser.Alpaca
  ];

in
{
  imports = [
    ./cliphist
    ./fuzzel
    ./hypridle
    ./niri
    ./swaync
    ./swayosd
    ./waybar

  ];

  environment.systemPackages = niriPackages ++ niriScripts ++ niriFonts;

  cli = {
    ghostty.enable = true;
  };

}
