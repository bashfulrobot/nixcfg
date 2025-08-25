#!/usr/bin/env bash

# AirPods (rempods) device identifiers - using MAC address pattern
REMPODS_SOURCE=$(pactl list sources short | grep "bluez_input.40:B3:FA:22:AF:6B" | cut -f2)
REMPODS_SINK=$(pactl list sinks short | grep "bluez_output.40_B3_FA_22_AF_6B" | head -1 | cut -f2)

echo "🎧 Switching to rempods (AirPods)..."

# Set default source (microphone input)
if [ -n "$REMPODS_SOURCE" ]; then
  pactl set-default-source "$REMPODS_SOURCE"
  echo "✅ Input set to: rempods"
  
else
  echo "❌ rempods input not found (make sure they're connected)"
fi

# Set default sink (audio output)
if [ -n "$REMPODS_SINK" ]; then
  pactl set-default-sink "$REMPODS_SINK"
  echo "✅ Output set to: rempods"
  
else
  echo "❌ rempods output not found (make sure they're connected)"
fi

echo "🎧 Audio setup complete!"