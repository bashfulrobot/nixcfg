{
  lib,
  pkgs,
  config,
  ...
}:
let

  # Niri-specific scripts from shared tiling scripts location
  niriScripts = [
    (pkgs.writeShellScriptBin "fuzzel-window-picker" (builtins.readFile ../../../module-config/scripts/fuzzel-window-picker.sh))
    (pkgs.writeShellScriptBin "niri-keybinds-help" (builtins.readFile ../../../module-config/scripts/niri-keybinds-help.sh))
    (pkgs.writeShellScriptBin "waybar-cava" (builtins.readFile ../../../module-config/scripts/WaybarCava.sh))
    (pkgs.writeShellScriptBin "gpuinfo" (builtins.readFile ../../../module-config/scripts/gpuinfo.sh))
    (pkgs.writeShellScriptBin "keyboardswitch" (builtins.readFile ../../../module-config/scripts/keyboardswitch.sh))
  ];

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
    swww

    # Idle and lock
    hypridle
    swaylock
    hyprlock

    # OSD
    swayosd

    # Authentication agent
    polkit_gnome
    seahorse

    # Keyring and secret management
    gcr_4 # GCR 4.x for modern keyring password prompts
    libsecret # Secret storage API

    # File manager
    nautilus
    nemo

    # System tools
    pavucontrol
    brightnessctl
    #blueman

    # Media controls
    playerctl
    pulseaudio  # for pactl

    # Session management
    greetd.tuigreet

    # Required for scripts
    jq

    # X11 app support
    xwayland-satellite

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

  ];

  environment.systemPackages = niriPackages ++ niriScripts ++ niriFonts;

  cli = {
    ghostty.enable = true;
  };

}
