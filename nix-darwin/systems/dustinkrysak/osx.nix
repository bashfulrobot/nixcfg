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

}