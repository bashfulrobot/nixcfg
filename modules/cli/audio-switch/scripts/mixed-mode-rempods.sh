#!/usr/bin/env bash

# Mixed mode: MV7 for input, rempods for output
MV7_SOURCE="alsa_input.usb-Shure_Inc_Shure_MV7-00.mono-fallback"
REMPODS_SINK=$(pactl list sinks short | grep "bluez_output.40_B3_FA_22_AF_6B" | head -1 | cut -f2)

echo "🎤🎧 Setting up mixed mode (MV7 input + rempods output)..."

# Set MV7 as input
if pactl list sources short | grep -q "$MV7_SOURCE"; then
  pactl set-default-source "$MV7_SOURCE"
  echo "✅ Input set to: Shure MV7"
  
else
  echo "❌ Shure MV7 input not found"
fi

# Set rempods as output
if [ -n "$REMPODS_SINK" ]; then
  pactl set-default-sink "$REMPODS_SINK"
  echo "✅ Output set to: rempods"
  
else
  echo "❌ rempods output not found (make sure they're connected)"
fi

echo "🎧 Mixed mode setup complete!"