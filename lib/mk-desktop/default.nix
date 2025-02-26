{ pkgs, lib, makeDesktopItem, ... }:

let
  makeDesktopApp = { name, binary, myStartupWMClass, iconSizes, iconPath }:
    let
      desktopName =
        lib.strings.toLower (lib.strings.replaceStrings [ " " ] [ "_" ] name);
      desktopItem = makeDesktopItem {
        type = "Application";
        name = desktopName;
        desktopName = name;
        startupWMClass = myStartupWMClass;
        exec = binary;
        icon = desktopName;
        categories = [ "Application" ];
      };

      icons = map (size:
        pkgs.stdenv.mkDerivation {
          name = "${desktopName}-icon-${size}";
          src = "${iconPath}/${size}.png";
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/share/icons/hicolor/${size}x${size}/apps
            cp $src $out/share/icons/hicolor/${size}x${size}/apps/${desktopName}.png
          '';
        }) iconSizes;
    in {
      assertions = [
        {
          assertion = name != null;
          message = "name is a required parameter for makeDesktopApp";
        }
        {
          assertion = binary != null;
          message = "binary is a required parameter for makeDesktopApp";
        }
        {
          assertion = myStartupWMClass != null;
          message = "startupWMClass is a required parameter for makeDesktopApp";
        }
        {
          assertion = iconSizes != null;
          message = "iconSizes is a required parameter for makeDesktopApp";
        }
        {
          assertion = iconPath != null;
          message = "iconPath is a required parameter for makeDesktopApp";
        }
      ];
      inherit desktopItem;
      inherit icons;
    };
in makeDesktopApp