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

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, zen-browser, stylix, declarative-flatpak, system-manager, ... }: {
    homeConfigurations = {
      "dustin@donkey-kong" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            })
          ];
        };

        extraSpecialArgs = {
          user-settings = builtins.fromJSON (builtins.readFile "${self}/../settings/settings.json");
          secrets = builtins.fromJSON (builtins.readFile "${self}/../secrets/secrets.json");
          inherit zen-browser;
          system = "x86_64-linux";
        };

        modules = [
          stylix.homeModules.stylix
          declarative-flatpak.homeModule
          ./modules/home/autoimport.nix
          ./hosts/donkey-kong
        ];
      };
    };

    systemConfigs = {
      donkey-kong = inputs.system-manager.lib.makeSystemConfig {
        modules = [
          ./modules/system/autoimport.nix
        ];
      };
    };
  };
}