{ config, pkgs, lib, ... }:

{
  # Host-specific system configuration for donkey-kong
  config = {
    # Enable applications at system level (AppArmor profiles, system services, etc.)
    apps = {
      chromium.enable = true;   # Enable AppArmor profile for Chromium
      onepassword.enable = true; # Enable AppArmor profile for 1Password
    };

    # Enable CLI tools at system level
    cli = {
      direnv.enable = true;  # System-level direnv support
    };

    # Host-specific system packages
    environment.systemPackages = with pkgs; [
      # Add host-specific system packages here
      apparmor-utils  # Required for AppArmor profile management
    ];

    # Host-specific systemd services
    systemd.services = {
      # Example host-specific service
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