{ config, pkgs, lib, ... }:

{
  boot = {
    # Use latest kernel for newer hardware support
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "quiet" "splash" ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "max"; # ensure windows will be found in boot menu
        netbootxyz.enable = false;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelModules = [ "usb" "xhci_hcd" "btusb" "bluetooth" ];
  };

  # LUKS configuration is handled entirely by disko.nix
}