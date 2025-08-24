{ config, lib, pkgs, user-settings, ... }:

let
  cfg = config.cli.audio-switch;

  mv7-script = pkgs.writeShellScriptBin "mv7" ''
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
  '';

  speakers-script = pkgs.writeShellScriptBin "speakers" ''
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
  '';

  rempods-script = pkgs.writeShellScriptBin "rempods" ''
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
  '';

  earmuffs-script = pkgs.writeShellScriptBin "earmuffs" ''
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
  '';

  mixed-mode-rempods-script = pkgs.writeShellScriptBin "mixed-mode-rempods" ''
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
  '';

  mixed-mode-earmuffs-script = pkgs.writeShellScriptBin "mixed-mode-earmuffs" ''
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
  '';

  audio-list-script = pkgs.writeShellScriptBin "audio-list" ''
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
  '';

in
{
  options.cli.audio-switch = {
    enable = lib.mkEnableOption "audio switching scripts";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      mv7-script
      rempods-script
      earmuffs-script
      mixed-mode-rempods-script
      mixed-mode-earmuffs-script
      speakers-script
      audio-list-script
    ];

    # Add fish shell aliases
    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable {
      mv7 = "mv7";
      rempods = "rempods";
      earmuffs = "earmuffs";
      mixed-mode-rempods = "mixed-mode-rempods";
      mixed-mode-earmuffs = "mixed-mode-earmuffs";
      speakers = "speakers";
      audio-list = "audio-list";
    };
  };
}