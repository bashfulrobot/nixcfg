{ pkgs, lib, fetchFromGitHub, ... }:
{
  # Create overlay that provides all COSMIC packages
  cosmicOverlay = final: prev: 
    # Import all package definitions similar to cosmic-unstable flake
    import ./pkgs/default.nix final prev;


  # Utility function for pinning specific packages (takes prev as argument)
  pinCosmicPackage = prev: packageName: repo: rev: hash: {
    ${packageName} = prev.${packageName}.overrideAttrs (oldAttrs: {
      src = fetchFromGitHub {
        owner = "pop-os";
        inherit repo rev hash;
      };
    });
  };

}