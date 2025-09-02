{ user-settings, pkgs, ... }:

let
  swayosd-custom = pkgs.writeShellApplication {
    name = "swayosd-custom";
    text = ''
    # Custom swayosd indicators script
    # Usage: ./swayosd-custom.sh <command> [args]

    case "$1" in
      "battery")
        # Show battery level as progress bar
        battery_level=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
        if [[ -n "$battery_level" ]]; then
          ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$battery_level"
        fi
        ;;

      "microphone-volume")
        # Show microphone volume level
        mic_volume=$(${pkgs.pamixer}/bin/pamixer --default-source --get-volume 2>/dev/null || echo "0")
        ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$mic_volume"
        ;;

      "cpu-temp")
        # Show CPU temperature as progress (scaled to 0-100)
        temp=$(${pkgs.lm_sensors}/bin/sensors 2>/dev/null | grep -i "core 0" | awk '{print $3}' | tr -d '+°C' | cut -d'.' -f1)
        if [[ -n "$temp" && "$temp" =~ ^[0-9]+$ ]]; then
          # Scale temperature: 30°C = 0%, 80°C = 100%
          scaled_temp=$(( (temp - 30) * 2 ))
          [[ $scaled_temp -lt 0 ]] && scaled_temp=0
          [[ $scaled_temp -gt 100 ]] && scaled_temp=100
          ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$scaled_temp"
        fi
        ;;

      "memory-usage")
        # Show memory usage percentage
        mem_usage=$(${pkgs.procps}/bin/free | grep "Mem:" | awk '{printf "%.0f", $3/$2 * 100}')
        ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$mem_usage"
        ;;

      "wifi-strength")
        # Show WiFi signal strength
        wifi_strength=$(${pkgs.wirelesstools}/bin/iwconfig 2>/dev/null | grep "Signal level" | sed 's/.*Signal level=\([0-9-]*\).*/\1/' | head -1)
        if [[ -n "$wifi_strength" ]]; then
          # Convert dBm to percentage (rough approximation)
          # -30 dBm = 100%, -90 dBm = 0%
          percentage=$(( (wifi_strength + 90) * 100 / 60 ))
          [[ $percentage -lt 0 ]] && percentage=0
          [[ $percentage -gt 100 ]] && percentage=100
          ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$percentage"
        fi
        ;;

      "disk-usage")
        # Show disk usage for specified path (default: home directory)
        path="''${2:-$HOME}"
        disk_usage=$(${pkgs.coreutils}/bin/df "$path" | awk 'NR==2 {print int($5)}' | tr -d '%')
        ${pkgs.swayosd}/bin/swayosd-client --custom-progress "$disk_usage"
        ;;

      *)
        echo "Usage: $0 {battery|microphone-volume|cpu-temp|memory-usage|wifi-strength|disk-usage [path]}"
        echo "Custom swayosd progress indicators for system monitoring"
        echo ""
        echo "Available commands:"
        echo "  battery           - Show battery level"
        echo "  microphone-volume - Show microphone volume"
        echo "  cpu-temp          - Show CPU temperature (scaled 30-80°C)"
        echo "  memory-usage      - Show RAM usage percentage"
        echo "  wifi-strength     - Show WiFi signal strength"
        echo "  disk-usage [path] - Show disk usage (default: home directory)"
        exit 1
        ;;
    esac
    '';
  };
in
{
  # Install packages for swayosd custom indicators
  environment.systemPackages = with pkgs; [
    swayosd
    pamixer      # For microphone volume
    lm_sensors   # For CPU temperature
    procps       # For memory usage (free command)
    wirelesstools # For WiFi strength (iwconfig)
    coreutils    # For disk usage (df command)
  ];

  home-manager.users."${user-settings.user.username}" = {
    services.swayosd = {
      enable = true;
      package = pkgs.swayosd;
      topMargin = 0.9; # Position OSD towards bottom of screen
      stylePath = null; # Use default styling for now
    };

    # Make swayosd-custom script available in user's PATH
    home.packages = [ swayosd-custom ];
  };
}