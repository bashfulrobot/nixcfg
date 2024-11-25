{ config, pkgs, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dustin = {
    isNormalUser = true;
    initialPassword = "changeme";
    description = "Dustin Krysak";
    extraGroups =
      [ "docker" "wheel" "kvm" "qemu-libvirtd" "libvirtd" "networkmanager" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];
  };
}
