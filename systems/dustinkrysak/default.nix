{ user-settings, config, pkgs, lib, inputs, ... }:

{
  imports = [
    # ./config/autoimport.nix
    # ../../modules/autoimport.nix
    # ../../archetype/autoimport.nix
    # ../../suites/autoimport.nix
    # ../../modules/cli/git/default.nix
  ];

  # archetype.workstation.enable = true;

  networking.hostName = "dustinkrysak"; # Define your hostname.

  # cli.git.enable = false;

  services.nix-daemon = {
    enable = true; # Enable the nix-darwin system
    logFile = "/var/log/nix-daemon.log"; # Set the log file
  };

  # in your configuration to disable nix-darwin’s own Nix management
  nix.enable = true;

  # Enable sudo/touchid integration
  security.pam.enableSudoTouchIdAuth = true;

  # Enable Homebrew
  homebrew.enable = true;

  # Enable some common services
  # services.icloud.enable = true;
  #services.ssh.enable = true;

  # Set some system options
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.schedule = "daily";

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

  system.stateVersion = 5;
}
