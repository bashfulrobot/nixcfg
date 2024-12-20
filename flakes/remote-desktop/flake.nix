{
  description = "A flake to run Chromium with the remote desktop extension";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosModules.default = { config, lib, pkgs, ... }: {
        programs.chromium = {
          enable = true;
          extensions = [ "inomeogfingihgjfjlpeplalcfajhgai" ];
        };
      };

      defaultPackage.${system} = pkgs.writeShellScriptBin "run-chromium" ''
        ${pkgs.chromium}/bin/chromium
      '';
    };
}
