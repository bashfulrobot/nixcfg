{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-unite";
  version = "82";

  src = fetchFromGitHub {
    owner = "hardpixel";
    repo = "unite-shell";
    rev = "v${version}";
    sha256 = "sha256-Ceo0HQupiihD6GW6/PUbjuArOXtPtAmUPxmNi7DS8E0=";
  };

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/share/gnome-shell/extensions/
    cp -r unite@hardpixel.eu $out/share/gnome-shell/extensions/
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Unite Shell - Makes GNOME Shell look like Ubuntu Unity Shell";
    homepage = "https://github.com/hardpixel/unite-shell";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };

  passthru = {
    extensionUuid = "unite@hardpixel.eu";
  };
}