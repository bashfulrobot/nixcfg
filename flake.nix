{
  description = "NixOS configuration for Dustin Krysak";

  # --- defines external dependencies (inputs)
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
    nixvim = {
      # url = "github:nix-community/nixvim/nixos-24.11";
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ghostty = {
    #   url = "github:ghostty-org/ghostty";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprflake = {
      url = "github:bashfulrobot/hyprflake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # --- outputs function receives all inputs as parameters
  # inputs@{...} syntax captures all inputs in a variable called inputs
  # self refers to the flake itself
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak
    , disko, nixos-hardware, nixvim, catppuccin, hyprflake, ... }:
    let
      # --- Creates an overlay that makes the unstable nixpkgs available under pkgs.unstable
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
          config.nvidia.acceptLicense = true;
        };
      };

      workstationOverlays = [ overlay-unstable ];

      secrets =
        builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");

      user-settings =
        builtins.fromJSON (builtins.readFile "${self}/settings/settings.json");

      commonModules = [
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        nixvim.nixosModules.nixvim
        catppuccin.nixosModules.catppuccin
        hyprflake.nixosModules.default
      ];

      serverModules = [
        home-manager.nixosModules.home-manager
        nixvim.nixosModules.nixvim
        disko.nixosModules.disko
      ];

      commonHomeManagerConfig = {
        home-manager = {
          useUserPackages = true;
          sharedModules = [ hyprflake.homeManagerModules.default ];
          useGlobalPkgs = true;
          extraSpecialArgs = { inherit user-settings secrets inputs; };
          users."${user-settings.user.username}" = {
            imports = [ catppuccin.homeModules.catppuccin ];
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

      # --- function to create NixOS system configurations
      # isWorkstation is used to do in module conditional logic for workstation specific settings
      makeSystem = name: modules:
        { isWorkstation, ... }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit user-settings inputs secrets nixpkgs-unstable isWorkstation;
          };
          system = "x86_64-linux";
          inherit modules;
        };

    in {
      nixosConfigurations = {

        # --- Create nixos systems using the makeSystem function

        # Note: The `true` argument is used to determine if the system is a workstation or not
        digdug = makeSystem "digdug" (commonModules
          ++ [ ./systems/digdug commonHomeManagerConfig commonNixpkgsConfig ]) {
            isWorkstation = true;
          };
        # Note: The `true` argument is used to determine if the system is a workstation or not
        qbert = makeSystem "qbert" (commonModules
          ++ [ ./systems/qbert commonHomeManagerConfig commonNixpkgsConfig ]) {
            isWorkstation = true;
          };
        # Note: The `false` argument is used to determine if the system is a workstation or not
        srv = makeSystem "srv" (serverModules
          ++ [ ./systems/srv serverHomeManagerConfig commonNixpkgsConfig ]) {
            isWorkstation = false;
          };
      };
    };
}
