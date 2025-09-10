{
  description = "My first nix-darwin flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      darwin,
      nixpkgs-unstable,
      nixvim,
      mac-app-util,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      user-settings = builtins.fromJSON (builtins.readFile "${self}/settings/settings.json");
      secrets = builtins.fromJSON (builtins.readFile "${self}/../secrets/secrets.json");
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
        };
      };
      overlays = [ overlay-unstable ];
    in
    {
      darwinConfigurations."dustinkrysak" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          nixvim.nixDarwinModules.nixvim
          mac-app-util.darwinModules.default
          ./hosts/dustinkrysak/default.nix
          # Add overlay as a module
          {
            nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfree = true;
          }
        ];
        specialArgs = {
          inherit
            user-settings
            secrets
            inputs
            lib
            ;
          isWorkstation = true;
        };
      };
      extraSpecialArgs = {
        inherit
          user-settings
          secrets
          inputs
          lib
          ;
        isWorkstation = true;
      };
    };
}
