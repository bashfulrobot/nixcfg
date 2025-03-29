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

}
