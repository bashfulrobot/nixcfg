{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # ./config/autoimport.nix
    # ../../modules/autoimport.nix
    # ../../archetype/autoimport.nix
    # ../../suites/autoimport.nix
  ];

  # archetype.workstation.enable = true;

  networking.hostName = "digdugdeeper"; # Define your hostname.

  services.nix-daemon = {
    enable = true; # Enable the nix-darwin system
    logFile = "/var/log/nix-daemon.log"; # Set the log file
  };

  # Enable Homebrew
  homebrew.enable = true;

  # Enable some common services
  services.icloud.enable = true;
  services.ssh.enable = true;

  # Set some system options
  system.autoUpgrade.enable = true;
  system.autoUpgrade.schedule = "daily";
}
