#!/usr/bin/env bash

# Earmuffs device identifiers - using MAC address pattern
EARMUFFS_SOURCE=$(pactl list sources short | grep "bluez_input.C8:7B:23:53:F1:D6" | cut -f2)
EARMUFFS_SINK=$(pactl list sinks short | grep "bluez_output.C8_7B_23_53_F1_D6" | head -1 | cut -f2)

echo "🎧 Switching to earmuffs..."

# Set default source (microphone input)
if [ -n "$EARMUFFS_SOURCE" ]; then
  pactl set-default-source "$EARMUFFS_SOURCE"
  echo "✅ Input set to: earmuffs"
  
else
  echo "❌ earmuffs input not found (make sure they're connected)"
fi

# Set default sink (audio output)
if [ -n "$EARMUFFS_SINK" ]; then
  pactl set-default-sink "$EARMUFFS_SINK"
  echo "✅ Output set to: earmuffs"
  
else
  echo "❌ earmuffs output not found (make sure they're connected)"
fi

echo "🎧 Audio setup complete!"