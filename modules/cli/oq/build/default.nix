{ lib, pkgs, ... }:
# TODO: Periodically update to latest release
let version = "0.0.20";
in pkgs.stdenv.mkDerivation {
  name = "oq";
  dontConfigure = true;

  src = pkgs.fetchzip {
    url =
      "https://github.com/plutov/oq/releases/download/v${version}/oq_${version}_linux_amd64.tar.gz";
    sha256 = "sha256-vFDgOuFxgh8nVaW+BDeg6jIpLuuPjXbV+ZBjd5qoCvE=";
    stripRoot = false; # pass false to fetchzip to assume flat list of files
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/oq $out/bin/oq
    chmod +x $out/bin/oq
  '';

  meta = with lib; {
    description =
      "Terminal-based OpenAPI Spec (OAS) viewer - https://github.com/plutov/oq.";
    maintainers = [ ];
  };
}