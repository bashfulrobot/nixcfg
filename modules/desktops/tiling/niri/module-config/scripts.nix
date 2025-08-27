{ pkgs }:

[
  (pkgs.writeShellScript "fuzzel-window-picker" (builtins.readFile ./scripts/fuzzel-window-picker.sh))
  # Add more scripts here...
]