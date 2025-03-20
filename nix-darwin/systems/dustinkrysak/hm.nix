{ config, lib, pkgs, user-settings, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # Use mkMerge since my username has a "." in it.
  home-manager.users = lib.mkMerge [
    {
      "dustin.krysak" = { pkgs, ... }: {
        home.stateVersion = "24.11";
      };
    }
  ];

}
