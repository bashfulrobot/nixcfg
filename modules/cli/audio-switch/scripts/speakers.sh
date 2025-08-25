#!/usr/bin/env bash

# Find the main audio output (usually the motherboard audio)
MAIN_SINK=$(pactl list sinks short | grep -E "(pci.*analog|pci.*iec958)" | head -1 | cut -f2)

if [ -z "$MAIN_SINK" ]; then
  echo "❌ Could not find main speakers"
  exit 1
fi

echo "🔊 Switching to speakers..."
pactl set-default-sink "$MAIN_SINK"
echo "✅ Output set to: Speakers ($MAIN_SINK)"

