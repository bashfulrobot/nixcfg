{
  description = "NixOS configuration for Dustin Krysak";

  # --- defines external dependencies (inputs)
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-25.05";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nixai.url = "github:olafkfreund/nix-ai-help";
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

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # --- outputs function receives all inputs as parameters
  # inputs@{...} syntax captures all inputs in a variable called inputs
  # self refers to the flake itself
  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      flake-utils,
      claude-desktop,
      disko,
      nixos-hardware,
      stylix,
      nixai,
      ...
    }:
    let
      # --- Creates an overlay that makes the unstable nixpkgs available under pkgs.unstable
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
          config.nvidia.acceptLicense = true;
        };
      };

      # Import temporary fixes
      tempFixes = import ./temp-fixes.nix;

      workstationOverlays = [
        overlay-unstable
        tempFixes.tailscale-sandbox-fix
      ];

      # Pre-compute JSON files once for better performance
      secretsFile = "${self}/secrets/secrets.json";
      settingsFile = "${self}/settings/settings.json";
      secrets = builtins.fromJSON (builtins.readFile secretsFile);
      user-settings = builtins.fromJSON (builtins.readFile settingsFile);

      commonModules = [
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        stylix.nixosModules.stylix
      ];

      serverModules = [
        home-manager.nixosModules.home-manager
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
          users."${user-settings.user.username}" = {
            imports = [ ];
          };
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
      makeSystem =
        name: modules:
        { isWorkstation, ... }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              user-settings
              inputs
              secrets
              nixpkgs-unstable
              isWorkstation
              ;
          };
          system = "x86_64-linux";
          inherit modules;
        };

    in
    {
      nixosConfigurations = {

        # --- Create nixos systems using the makeSystem function

        # Note: The `true` argument is used to determine if the system is a workstation or not
        qbert =
          makeSystem "qbert"
            (
              commonModules
              ++ [
                ./hosts/qbert
                commonHomeManagerConfig
                commonNixpkgsConfig
              ]
            )
            {
              isWorkstation = true;
            };
        donkeykong =
          makeSystem "donkeykong"
            (
              commonModules
              ++ [
                ./hosts/donkeykong
                commonHomeManagerConfig
                commonNixpkgsConfig
              ]
            )
            {
              isWorkstation = true;
            };
        # Note: The `false` argument is used to determine if the system is a workstation or not
        srv =
          makeSystem "srv"
            (
              serverModules
              ++ [
                ./hosts/srv
                serverHomeManagerConfig
                commonNixpkgsConfig
              ]
            )
            {
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
