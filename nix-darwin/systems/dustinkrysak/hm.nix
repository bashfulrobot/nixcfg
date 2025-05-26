{ config, lib, pkgs, user-settings, inputs, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # Use mkMerge since my username has a "." in it.
  home-manager.users = lib.mkMerge [{
    "dustin.krysak" = { pkgs, ... }: {
      home.stateVersion = "25.05";

      # Import the mac-app-util module
      imports = [ inputs.mac-app-util.homeManagerModules.default ];

      # Now any packages with /Applications/ directories will be available in Spotlight
      # and the App Launcher without additional configuration
    };
  }];

}
