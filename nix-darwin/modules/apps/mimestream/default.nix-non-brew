{ config, lib, pkgs, ... }:

let
  cfg = config.apps.mimestream;
  version = "1.6.1";

  mimestream = pkgs.stdenvNoCC.mkDerivation {
    pname = "mimestream";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://download.mimestream.com/Mimestream_${version}.dmg";
      sha256 = "sha256-g4Tx4a8HkYDMz26XL+rz2a/+4rinLjNXAHKocdEdMlo=";
    };

    nativeBuildInputs = [ pkgs.undmg ];

    # Disable unnecessary phases
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;

    # Extract to current directory
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications

      # Find and copy the .app directory
      for d in *; do
        if [ -d "$d" ] && [[ "$d" == *.app ]]; then
          echo "Found app bundle: $d"
          cp -r "$d" $out/Applications/
        fi
      done

      runHook postInstall
    '';
  };
in {
  options = {
    apps.mimestream.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Mimestream Gmail Client.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Add the app to system packages
    environment.systemPackages = [ mimestream ];

    # Direct installation method for /Applications
    system.activationScripts.postActivation.text = lib.mkAfter ''
      # Install Mimestream to system /Applications
      app_src="${mimestream}/Applications/Mimestream.app"
      app_dst="/Applications/Mimestream.app"

      # Only create install if the source app exists
      if [ -d "$app_src" ]; then
        echo "Installing Mimestream.app to /Applications/"

        # Make a direct copy
        sudo rm -rf "$app_dst"
        sudo cp -R "$app_src" "$app_dst"

        # Set appropriate timestamps to avoid "unknown date" warning
        NOW=$(date)
        sudo touch -d "$NOW" "$app_dst"

        # Remove quarantine attribute if present
        sudo xattr -rd com.apple.quarantine "$app_dst" 2>/dev/null || true

        # Fix permissions
        sudo chown -R root:wheel "$app_dst"

        # Try to register with Launch Services to refresh app info
        /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app_dst"

        echo "Mimestream.app installed - You may need to right-click > Open the first time"
      else
        echo "Warning: Mimestream.app not found at $app_src"
      fi
    '';
  };
}