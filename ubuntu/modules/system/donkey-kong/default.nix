{ config, pkgs, lib, ... }:

{
  # App modules are auto-imported via autoimport.nix

  # Host-specific system configuration for donkey-kong
  config = {
    # Enable applications at system level
    apps.onepassword.enable = true;
    
    # Configure /etc files
    environment.etc = {
      # Host-specific configuration files
      # "donkey-kong-specific.conf".text = ''
      #   hostname = "donkey-kong"
      # '';
    };

    # System packages available system-wide (host-specific)
    environment.systemPackages = with pkgs; [
      # Add host-specific system packages here
      # curl
      # wget
      # htop
    ];

    # Systemd services (host-specific)
    systemd.services = {
      # Host-specific services
      # "donkey-kong-service" = {
      #   description = "Host-specific service";
      #   wantedBy = [ "multi-user.target" ];
      #   serviceConfig = {
      #     Type = "simple";
      #     ExecStart = "${pkgs.hello}/bin/hello";
      #   };
      # };
    };
  };
}