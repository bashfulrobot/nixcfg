{
  description = "Home Manager configuration for Ubuntu systems - Dustin Krysak";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-25.05"; };
    nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    declarative-flatpak = {
      url = "github:in-a-dil-emma/declarative-flatpak/stable-v3";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, zen-browser, stylix, declarative-flatpak, ... }:
    let
      system = "x86_64-linux";

      # Create overlay for unstable packages
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
        };
      };

      # Load settings and secrets from parent directory
      user-settings = builtins.fromJSON (builtins.readFile "${self}/../settings/settings.json");
      secrets = builtins.fromJSON (builtins.readFile "${self}/../secrets/secrets.json");

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay-unstable ];
      };

      # Helper function to create home-manager configurations for different hosts
      mkHomeConfig = hostname: {
        "${user-settings.user.username}@${hostname}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit user-settings secrets inputs system;
            inherit (inputs) zen-browser;
          };

          modules = [
            stylix.homeManagerModules.stylix
            declarative-flatpak.homeManagerModules.declarative-flatpak
            ./autoimport.nix
            ./hosts/${hostname}
          ];
        };
      };

    in {
      homeConfigurations = 
        (mkHomeConfig "donkey-kong") //
        # Add other Ubuntu systems here as needed
        # (mkHomeConfig "other-ubuntu-system") //
        {};

      # Expose packages for development
      packages.${system} = {
        inherit (pkgs) home-manager;
      };
    };
}