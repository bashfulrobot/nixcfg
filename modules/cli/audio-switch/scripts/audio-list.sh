#!/usr/bin/env bash

echo "🎤 Available Audio Sources:"
pactl list sources short | grep -v monitor
echo
echo "🔊 Available Audio Sinks:"
pactl list sinks short
echo
echo "Current defaults:"
echo "Input:  $(pactl get-default-source)"
echo "Output: $(pactl get-default-sink)"