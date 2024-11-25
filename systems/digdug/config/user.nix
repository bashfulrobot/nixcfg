{ config, pkgs, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dustin = {
    isNormalUser = true;
    description = "Dustin Krysak";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];
  };
}
