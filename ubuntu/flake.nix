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
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, zen-browser, stylix, declarative-flatpak, system-manager, ... }:
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
            stylix.homeModules.stylix
            declarative-flatpak.homeModule
            ./modules/home/autoimport.nix
            ./hosts/${hostname}
          ];
        };
      };

      # Helper function to create system-manager configurations for different hosts
      mkSystemConfig = hostname: {
        "${hostname}" = system-manager.lib.makeSystemConfig {
          extraSpecialArgs = {
            inherit user-settings;
          };
          modules = [
            ./modules/system/autoimport.nix
            ./modules/mixed
            # ./modules/system/${hostname}
          ];
        };
      };

    in {
      homeConfigurations =
        (mkHomeConfig "donkey-kong") //
        # Add other Ubuntu systems here as needed
        # (mkHomeConfig "other-ubuntu-system") //
        {};

      systemConfigs =
        (mkSystemConfig "donkey-kong") //
        # Add other Ubuntu systems here as needed
        # (mkSystemConfig "other-ubuntu-system") //
        {};

      # Expose packages for development
      packages.${system} = {
        inherit (pkgs) home-manager;
      };
    };
}