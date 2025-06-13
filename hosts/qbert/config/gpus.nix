{ config, pkgs, ... }:
{
  # The kernel can load the correct driver right away:
  boot = {
    initrd.kernelModules = [ "amdgpu" ];
    # tshooting desktop lockups
    # kernelParams = [
    #   "amdgpu.dc=0" # Disable Display Core
    #   "amdgpu.gfxoff=0" # Disable power gating
    # ];
  };
  # Make sure Xserver uses the `amdgpu` driver
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics = {
    # For 32 bit applications
    enable32Bit = true;
    enable = true;
  };

}
