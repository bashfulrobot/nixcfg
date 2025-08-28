pkgs: [
  (pkgs.writeShellScriptBin "fuzzel-window-picker" (builtins.readFile ./fuzzel-window-picker.sh))
  (pkgs.writeShellScriptBin "niri-keybinds-help" (builtins.readFile ./niri-keybinds-help.sh))
  # Add more niri-specific scripts here...
]