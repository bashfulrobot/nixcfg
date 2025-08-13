#!/usr/bin/env bash

# Audio Source Management Script for Waybar
# Provides a rofi menu to select audio input/output sources

# Icons for different device types
get_device_icon() {
    local desc="$1"
    case "$desc" in
        *"Headphone"*|*"headphone"*) echo "󰋋" ;;
        *"Headset"*|*"headset"*) echo "󰋎" ;;
        *"Speaker"*|*"speaker"*) echo "󰓃" ;;
        *"Microphone"*|*"microphone"*|*"Mic"*|*"mic"*) echo "󰍬" ;;
        *"Bluetooth"*|*"bluetooth"*) echo "󰂯" ;;
        *"USB"*|*"usb"*) echo "󰌷" ;;
        *"Built-in"*|*"built-in"*|*"Internal"*|*"internal"*) echo "󰋋" ;;
        *) echo "󰕾" ;;
    esac
}

# Get current default sink/source
current_sink=$(pactl get-default-sink)
current_source=$(pactl get-default-source)

# Build output devices menu
output_devices=""
while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*index:[[:space:]]*([0-9]+) ]]; then
        index="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^[[:space:]]*name:[[:space:]]*\<(.+)\> ]]; then
        name="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^[[:space:]]*device.description[[:space:]]*=[[:space:]]*\"(.+)\" ]]; then
        desc="${BASH_REMATCH[1]}"
        icon=$(get_device_icon "$desc")
        
        # Mark current device
        if [[ "$name" == "$current_sink" ]]; then
            output_devices+="🔊 $icon $desc ✓\n"
        else
            output_devices+="🔊 $icon $desc\n"
        fi
    fi
done < <(pactl list sinks)

# Build input devices menu
input_devices=""
while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*index:[[:space:]]*([0-9]+) ]]; then
        index="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^[[:space:]]*name:[[:space:]]*\<(.+)\> ]]; then
        name="${BASH_REMATCH[1]}"
    elif [[ $line =~ ^[[:space:]]*device.description[[:space:]]*=[[:space:]]*\"(.+)\" ]]; then
        desc="${BASH_REMATCH[1]}"
        icon=$(get_device_icon "$desc")
        
        # Mark current device
        if [[ "$name" == "$current_source" ]]; then
            input_devices+="🎤 $icon $desc ✓\n"
        else
            input_devices+="🎤 $icon $desc\n"
        fi
    fi
done < <(pactl list sources | grep -v "monitor")

# Combine menus with separator
menu_options=""
if [[ -n "$output_devices" ]]; then
    menu_options+="─── 🔊 OUTPUT DEVICES ───\n"
    menu_options+="$output_devices"
fi

if [[ -n "$input_devices" ]]; then
    if [[ -n "$output_devices" ]]; then
        menu_options+="\n"
    fi
    menu_options+="─── 🎤 INPUT DEVICES ───\n"
    menu_options+="$input_devices"
fi

# Add control options
menu_options+="\n─── 🎛️  CONTROLS ───\n"
menu_options+="🔧 Open PulseAudio Control\n"
menu_options+="🔇 Toggle Mute Output\n"
menu_options+="🎤 Toggle Mute Input"

# Show rofi menu
selected=$(echo -e "$menu_options" | rofi -dmenu -p "Audio Sources" -theme-str "window {width: 400px;}" -i)

# Handle selection
case "$selected" in
    "🔧 Open PulseAudio Control")
        pavucontrol &
        ;;
    "🔇 Toggle Mute Output")
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+%' | head -1)
        mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
        if [[ "$mute_status" == "yes" ]]; then
            notify-send "🔇 Audio" "Output Muted" -t 2000
        else
            notify-send "🔊 Audio" "Output Unmuted ($volume)" -t 2000
        fi
        ;;
    "🎤 Toggle Mute Input")
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        mute_status=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')
        if [[ "$mute_status" == "yes" ]]; then
            notify-send "🔇 Audio" "Microphone Muted" -t 2000
        else
            notify-send "🎤 Audio" "Microphone Unmuted" -t 2000
        fi
        ;;
    "─── 🔊 OUTPUT DEVICES ───"|"─── 🎤 INPUT DEVICES ───"|"─── 🎛️  CONTROLS ───"|"")
        # Ignore separator lines and empty selection
        ;;
    *)
        if [[ $selected == 🔊* ]]; then
            # Output device selected
            device_desc=$(echo "$selected" | sed 's/🔊 [^ ]* //' | sed 's/ ✓$//')
            
            # Find the device name by description
            device_name=""
            while IFS= read -r line; do
                if [[ $line =~ ^[[:space:]]*name:[[:space:]]*\<(.+)\> ]]; then
                    name="${BASH_REMATCH[1]}"
                elif [[ $line =~ ^[[:space:]]*device.description[[:space:]]*=[[:space:]]*\"(.+)\" ]]; then
                    desc="${BASH_REMATCH[1]}"
                    if [[ "$desc" == "$device_desc" ]]; then
                        device_name="$name"
                        break
                    fi
                fi
            done < <(pactl list sinks)
            
            if [[ -n "$device_name" ]]; then
                pactl set-default-sink "$device_name"
                notify-send "🔊 Audio Output" "Switched to: $device_desc" -t 3000
            fi
            
        elif [[ $selected == 🎤* ]]; then
            # Input device selected
            device_desc=$(echo "$selected" | sed 's/🎤 [^ ]* //' | sed 's/ ✓$//')
            
            # Find the device name by description
            device_name=""
            while IFS= read -r line; do
                if [[ $line =~ ^[[:space:]]*name:[[:space:]]*\<(.+)\> ]]; then
                    name="${BASH_REMATCH[1]}"
                elif [[ $line =~ ^[[:space:]]*device.description[[:space:]]*=[[:space:]]*\"(.+)\" ]]; then
                    desc="${BASH_REMATCH[1]}"
                    if [[ "$desc" == "$device_desc" ]]; then
                        device_name="$name"
                        break
                    fi
                fi
            done < <(pactl list sources | grep -v "monitor")
            
            if [[ -n "$device_name" ]]; then
                pactl set-default-source "$device_name"
                notify-send "🎤 Audio Input" "Switched to: $device_desc" -t 3000
            fi
        fi
        ;;
esac