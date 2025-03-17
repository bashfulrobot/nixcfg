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
    nixvim = {
      # url = "github:nix-community/nixvim/nixos-24.11";
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
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
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, nix-flatpak
    , disko, nixos-hardware, nixvim, catppuccin, nix-darwin, ... }:
    let
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

      # system = "x86_64-linux";  # Define the system variable

      user-settings-linux = builtins.fromJSON (builtins.readFile "${self}/settings/settings-linux.json");
      user-settings-darwin = builtins.fromJSON (builtins.readFile "${self}/settings/settings-darwin.json");

      commonModules = [
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        nixvim.nixosModules.nixvim
        catppuccin.nixosModules.catppuccin
      ];

      serverModules = [
        home-manager.nixosModules.home-manager
        nixvim.nixosModules.nixvim
        disko.nixosModules.disko
      ];

      commonHomeManagerConfig = settings: {
  home-manager = {
    useUserPackages = true;
    sharedModules = [ ];
    useGlobalPkgs = true;
    extraSpecialArgs = { user-settings = settings; inherit secrets inputs; };
    users."${settings.user.username}" = {
      imports = [ catppuccin.homeManagerModules.catppuccin ];
      home.stateVersion = "24.11";
      # Dynamically build the path based on the platform and username
      home.homeDirectory = nixpkgs.lib.mkForce (
        if settings.user ? system && settings.user.system == "Darwin"
        then "/Users/${settings.user.username}"
        else "/home/${settings.user.username}"
      );
    };
  };
};

      serverHomeManagerConfig = settings: {
        home-manager = {
          useUserPackages = true;
          sharedModules = [ ];
          useGlobalPkgs = true;
          extraSpecialArgs = { user-settings = settings; inherit secrets inputs; };
          users."${settings.user.username}" = {
            imports = [ ];
            home.stateVersion = "24.11";  # Move this inside the user block
            # Dynamically build the path based on the platform and username
      home.homeDirectory = nixpkgs.lib.mkForce (
        if settings.user ? system && settings.user.system == "Darwin"
        then "/Users/${settings.user.username}"
        else "/home/${settings.user.username}"
      );

          };
        };
      };

      commonNixpkgsConfig = {
        nixpkgs = {
          overlays = workstationOverlays;
          config.allowUnfree = true;
        };
      };

      # isWorkstation is used to do in module conditional logic for workstation specific settings
      makeSystem = name: modules:
      { isWorkstation, ... }:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          user-settings = user-settings-linux;
          inherit inputs secrets nixpkgs-unstable isWorkstation;
        };
        system = "x86_64-linux";
        inherit modules;
      };

    makeDarwinSystem = name: modules:
      { isWorkstation, ... }:
      nix-darwin.lib.darwinSystem {
        specialArgs = {
          user-settings = user-settings-darwin;
          inherit inputs secrets nixpkgs-unstable isWorkstation;
        };
        system = "aarch64-darwin";
        inherit modules;
      };

    in {
     nixosConfigurations = {
  # Note: The `true` argument is used to determine if the system is a workstation or not
  digdug = makeSystem "digdug" (commonModules
    ++ [ ./systems/digdug
         (commonHomeManagerConfig user-settings-linux)
         commonNixpkgsConfig ]) {
      isWorkstation = true;
    };
  # Note: The `true` argument is used to determine if the system is a workstation or not
  qbert = makeSystem "qbert" (commonModules
    ++ [ ./systems/qbert
         (commonHomeManagerConfig user-settings-linux)
         commonNixpkgsConfig ]) {
      isWorkstation = true;
    };
  # Note: The `false` argument is used to determine if the system is a workstation or not
  srv = makeSystem "srv" (serverModules
    ++ [ ./systems/srv
         (serverHomeManagerConfig user-settings-linux)
         commonNixpkgsConfig ]) {
      isWorkstation = false;
    };
};

darwinConfigurations = {
  dustinkrysak = makeDarwinSystem "dustinkrysak" ([
    home-manager.darwinModules.home-manager
    ./systems/dustinkrysak
  ]) {
    isWorkstation = false;
  };
};
    };
}
