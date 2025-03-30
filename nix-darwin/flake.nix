{
  description = "My first nix-darwin flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, darwin, nixpkgs-unstable, nixvim, }:
    let
      lib = nixpkgs.lib;
      user-settings =
        builtins.fromJSON (builtins.readFile "${self}/settings/settings.json");
      secrets =
        builtins.fromJSON (builtins.readFile "${self}/../secrets/secrets.json");
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
        };
      };
      overlays = [ overlay-unstable ];
    in {
      darwinConfigurations."dustinkrysak" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          nixvim.nixDarwinModules.nixvim
          ./systems/dustinkrysak/default.nix
          # Add overlay as a module
          {
            nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfree = true;
          }
        ];
        specialArgs = {
          inherit user-settings secrets inputs lib;
          isWorkstation = true;
        };
      };
      extraSpecialArgs = {
        inherit user-settings secrets inputs lib;
        isWorkstation = true;
      };
    };
}
