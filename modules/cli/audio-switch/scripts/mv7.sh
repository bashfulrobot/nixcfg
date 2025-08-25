#!/usr/bin/env bash

# Shure MV7 device identifiers
MV7_SOURCE="alsa_input.usb-Shure_Inc_Shure_MV7-00.mono-fallback"
MV7_SINK="alsa_output.usb-Shure_Inc_Shure_MV7-00.iec958-stereo"

echo "🎤 Switching to Shure MV7..."

# Set default source (microphone input)
if pactl list sources short | grep -q "$MV7_SOURCE"; then
  pactl set-default-source "$MV7_SOURCE"
  echo "✅ Input set to: Shure MV7"
else
  echo "❌ Shure MV7 input not found"
fi

# Set default sink (audio output)
if pactl list sinks short | grep -q "$MV7_SINK"; then
  pactl set-default-sink "$MV7_SINK"
  echo "✅ Output set to: Shure MV7"
else
  echo "❌ Shure MV7 output not found"
fi

echo "🎧 Audio setup complete!"