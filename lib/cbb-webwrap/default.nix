{ pkgs, lib, makeDesktopItem, ... }:
#  https://peter.sh/experiments/chromium-command-line-switches/
let
  makeDesktopApp = { name, url, binary, myStartupWMClass, iconSizes, iconPath, useAppFlag ? true, enableLogging ? false }:
    let
      desktopName =
        lib.strings.toLower (lib.strings.replaceStrings [ " " ] [ "_" ] name);
      scriptPath = pkgs.writeShellScriptBin desktopName ''
        ${if enableLogging then ''
        # Log file in nixcfg repo root
        LOGFILE="/home/dustin/dev/nix/nixcfg/${desktopName}-debug.log"
        
        echo "Starting ${name} at $(date)" >> "$LOGFILE"
        echo "Command: ${binary} --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode,WaylandWindowDecorations --disable-features=TranslateUI --disable-default-apps --new-window ${if useAppFlag then "--profile-directory=WebApp-${desktopName} --app=${url}" else "${url}"}" >> "$LOGFILE"
        
        # Run with standard flags
        ${binary} --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode,WaylandWindowDecorations --disable-features=TranslateUI --disable-default-apps --new-window ${if useAppFlag then "--profile-directory=WebApp-${desktopName} --app=${url}" else "${url}"} >> "$LOGFILE" 2>&1 &
        
        # Store PID and wait
        PID=$!
        echo "Process ID: $PID" >> "$LOGFILE"
        wait $PID
        EXIT_CODE=$?
        echo "Process exited with code: $EXIT_CODE at $(date)" >> "$LOGFILE"
        
        # If crashed, also log to console
        if [ $EXIT_CODE -ne 0 ]; then
          echo "❌ ${name} crashed with exit code $EXIT_CODE. See log: $LOGFILE" >&2
        fi
        '' else ''
        ${binary} --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode,WaylandWindowDecorations --disable-features=TranslateUI --disable-default-apps --new-window ${if useAppFlag then "--profile-directory=WebApp-${desktopName} --app=${url}" else "${url}"}
        ''}
      '';
      desktopItem = makeDesktopItem {
        type = "Application";
        name = desktopName;
        desktopName = name;
        startupWMClass = myStartupWMClass;
        # exec = ''
        #   ${binary} --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode --new-window --app="${lib.escapeShellArg url}"
        # '';
        exec = "${scriptPath}/bin/${desktopName}"; # use the script to open the app - accounts for url encoding. which breaks due to the desktop file spec.
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
          assertion = url != null;
          message = "url is a required parameter for makeDesktopApp";
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
