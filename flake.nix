{
  description = "NixOS configuration for Dustin Krysak";

  # --- defines external dependencies (inputs)
  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-25.05"; };
    nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware/master"; };
    nixos-hardware-fork = { url = "github:bashfulrobot/nixos-hardware/master"; };
    nix-flatpak = { url = "github:gmodena/nix-flatpak"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      # url = "github:nix-community/nixvim/nixos-25.05";
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ghostty = {
    #   url = "github:ghostty-org/ghostty";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    opnix.url = "github:brizzbuzz/opnix";
    hyprflake = {
      url = "github:bashfulrobot/hyprflake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # --- outputs function receives all inputs as parameters
  # inputs@{...} syntax captures all inputs in a variable called inputs
  # self refers to the flake itself
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak, flake-utils, claude-desktop
    , disko, nixos-hardware, nixos-hardware-fork, nixvim, opnix, hyprflake, zen-browser, stylix, ... }:
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
        opnix.nixosModules.default
        stylix.nixosModules.stylix
      ];

      serverModules = [
        home-manager.nixosModules.home-manager
        nixvim.nixosModules.nixvim
        disko.nixosModules.disko
      ];

      commonHomeManagerConfig = {
        home-manager = {
          useUserPackages = true;
          sharedModules = [ ];
          useGlobalPkgs = true;
          extraSpecialArgs = { inherit user-settings secrets inputs; };
          users."${user-settings.user.username}" = {
            imports = [
              opnix.homeManagerModules.default
            ];
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
            inherit user-settings inputs secrets nixpkgs-unstable isWorkstation zen-browser;
          };
          system = "x86_64-linux";
          inherit modules;
        };

    in {
      nixosConfigurations = {

        # --- Create nixos systems using the makeSystem function

        # Note: The `true` argument is used to determine if the system is a workstation or not
        qbert = makeSystem "qbert" (commonModules
          ++ [ ./hosts/qbert commonHomeManagerConfig commonNixpkgsConfig ]) {
            isWorkstation = true;
          };
        donkeykong = makeSystem "donkeykong" (commonModules
          ++ [ ./hosts/donkeykong commonHomeManagerConfig commonNixpkgsConfig ]) {
            isWorkstation = true;
          };
        # Note: The `false` argument is used to determine if the system is a workstation or not
        srv = makeSystem "srv" (serverModules
          ++ [ ./hosts/srv serverHomeManagerConfig commonNixpkgsConfig ]) {
            isWorkstation = false;
          };
      };

      # --- Home Manager configurations for Ubuntu/non-NixOS systems
      # NOTE: Ubuntu configurations moved to ubuntu/ subfolder with separate flake
      homeConfigurations = {
        # Ubuntu configurations now managed by ubuntu/flake.nix
      };
    };
}
