{ lib, pkgs, ... }:
# https://download.sysdig.com/scanning/sysdig-cli-scanner/latest_version.txt
# TODO: UPDATE ME
let
  version = "1.22.1";

  system = pkgs.stdenv.hostPlatform.system;

  sources = {
    "x86_64-linux" = {
      url =
        "https://download.sysdig.com/scanning/bin/sysdig-cli-scanner/${version}/linux/amd64/sysdig-cli-scanner";
      sha256 = "sha256-ruN8eQ0OhdnUR4okMDhZ/352yVLYlEmWfnmdvskjyGU=";
    };
    "aarch64-darwin" = {
      url =
        "https://download.sysdig.com/scanning/bin/sysdig-cli-scanner/${version}/darwin/arm64/sysdig-cli-scanner";
      sha256 =
        "sha256-FDkqWstWMTtF0QLWk+iadJr7aRHRnpiatqAeoHftVDk="; # TODO: Add sha256 after first build attempt
    };
  };
in if sources ? ${system} then
  pkgs.stdenv.mkDerivation {
    name = "sysdig-cli-scanner";
    src = pkgs.fetchurl sources.${system};
    phases = [ "installPhase" "patchPhase" ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/sysdig-cli-scanner
      chmod +x $out/bin/sysdig-cli-scanner
    '';

    meta = with lib; {
      description =
        "Sysdig CLI Scanner - https://docs.sysdig.com/en/docs/installation/sysdig-secure/install-vulnerability-cli-scanner/.";
      maintainers = [ bashfulrobot ];
      platforms = [ "x86_64-linux" "aarch64-darwin" ];
    };
  }
else
  throw "Unsupported system: ${system}"
