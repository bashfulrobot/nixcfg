{ user-settings, pkgs, config, lib, ... }:
let cfg = config.dev.go;

in {
  options = {
    dev.go.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable go tooling with clang support for CGO.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      # keep-sorted start case=no numeric=yes
      clang
      llvm
      unstable.go
      # keep-sorted end
    ];

    # Set clang as default C/C++ compiler for CGO
    environment.variables = {
      CC = "${pkgs.clang}/bin/clang";
      CXX = "${pkgs.clang}/bin/clang++";
    };

    home-manager.users."${user-settings.user.username}" = {
      home.sessionVariables = {
        CC = "${pkgs.clang}/bin/clang";
        CXX = "${pkgs.clang}/bin/clang++";
      };
    };
  };
}
