{ config, pkgs, ... }:

{
  system.defaults = {
    # Autohide the dock
    dock.autohide = true;
    finder = {
      # Show all file exts in finder
      AppleShowAllExtensions = true;
      # Default to columns in finder
      FXPreferredViewStyle = "clmv";
    };
    screencapture.location = "~/Pictures/screenshots";
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  ### CustomSystemPreferences
  # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-system.defaults.CustomSystemPreferences
  # list set items -  defaults read

  ###  Investigate
  # - https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.khd.i3Keybindings
  # - https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.sketchybar.enable
  # - https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.tailscale.enable
  # -https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-services.yabai.enable

}
