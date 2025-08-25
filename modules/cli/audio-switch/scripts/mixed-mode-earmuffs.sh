#!/usr/bin/env bash

# Mixed mode: MV7 for input, earmuffs for output
MV7_SOURCE="alsa_input.usb-Shure_Inc_Shure_MV7-00.mono-fallback"
EARMUFFS_SINK=$(pactl list sinks short | grep "bluez_output.C8_7B_23_53_F1_D6" | head -1 | cut -f2)

echo "🎤🎧 Setting up mixed mode (MV7 input + earmuffs output)..."

# Set MV7 as input
if pactl list sources short | grep -q "$MV7_SOURCE"; then
  pactl set-default-source "$MV7_SOURCE"
  echo "✅ Input set to: Shure MV7"
  
else
  echo "❌ Shure MV7 input not found"
fi

# Set earmuffs as output
if [ -n "$EARMUFFS_SINK" ]; then
  pactl set-default-sink "$EARMUFFS_SINK"
  echo "✅ Output set to: earmuffs"
  
else
  echo "❌ earmuffs output not found (make sure they're connected)"
fi

echo "🎧 Mixed mode setup complete!"