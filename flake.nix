{
  description = "NixOS configuration for Dustin Krysak";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-24.11"; };
    nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware/master"; };
    nix-flatpak = { url = "github:gmodena/nix-flatpak"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager
    , nix-flatpak, disko, nixos-hardware, ... }:
    let
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
          config.nvidia.acceptLicense = true;
        };
      };

      workstationOverlays =
        [ overlay-unstable ];

      secrets =
        builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");

      user-settings =
        builtins.fromJSON (builtins.readFile "${self}/settings/settings.json");

      commonModules = [
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
      ];

      serverModules =
        [ home-manager.nixosModules.home-manager disko.nixosModules.disko ];

      commonHomeManagerConfig = {
        home-manager = {
          useUserPackages = true;
          sharedModules = [ ];
          useGlobalPkgs = true;
          extraSpecialArgs = { inherit user-settings secrets inputs; };
          users."${user-settings.user.username}" = {
            imports = [ ];
          };
        };
      };

      serverHomeManagerConfig = {
        home-manager = {
          useUserPackages = true;
          sharedModules = [ ];
          useGlobalPkgs = true;
          extraSpecialArgs = { inherit user-settings secrets inputs; };
          users."${user-settings.user.username}" = { imports = [ ]; };
        };
      };

      commonNixpkgsConfig = {
        nixpkgs = {
          overlays = workstationOverlays;
          config.allowUnfree = true;
        };
      };

      makeSystem = name: modules:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit user-settings inputs secrets nixpkgs-unstable;
          };
          system = "x86_64-linux";
          inherit modules;
        };

    in {
      nixosConfigurations = {
        vm = makeSystem "vm" (commonModules
          ++ [ ./systems/vm commonHomeManagerConfig commonNixpkgsConfig ]);
        # rembot = makeSystem "rembot" (commonModules
        #   ++ [ ./systems/rembot commonHomeManagerConfig commonNixpkgsConfig ]);
        # nixdo = makeSystem "nixdo" [ ./systems/nixdo ];
        # srv = makeSystem "srv" (serverModules
        #   ++ [ ./systems/srv serverHomeManagerConfig commonNixpkgsConfig ]);
      };
    };
}