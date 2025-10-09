{ pkgs, lib, makeDesktopItem, ... }:
#  https://peter.sh/experiments/chromium-command-line-switches/
let
  makeDesktopApp = { name, url, binary, iconSizes, iconPath, useAppFlag ? true, enableLogging ? false }:
    let
      desktopName =
        lib.strings.toLower (lib.strings.replaceStrings [ " " ] [ "_" ] name);

      # Predict the actual WM class that Chromium will generate for --app mode
      predictedWMClass =
        if useAppFlag then
          let
            # Extract browser prefix based on binary name
            browserPrefix =
              if lib.strings.hasInfix "chromium" binary then "chrome-"
              else if lib.strings.hasInfix "chrome" binary then "chrome-"
              else if lib.strings.hasInfix "brave" binary then "brave-"
              else "chrome-"; # fallback to chrome prefix

            # Parse URL to extract domain and path
            urlWithoutProtocol = lib.strings.removePrefix "https://" (lib.strings.removePrefix "http://" url);
            urlParts = lib.strings.splitString "/" urlWithoutProtocol;
            domain = lib.lists.head urlParts;
            pathParts = lib.lists.tail urlParts;
            pathString = if pathParts != [] then "__" + (lib.strings.concatStringsSep "_" pathParts) else "";

          in "${browserPrefix}${domain}${pathString}-Default"
        else desktopName;
      scriptPath = pkgs.writeShellScriptBin desktopName ''
        ${if enableLogging then ''
        # Log file in nixcfg repo root
        LOGFILE="/home/dustin/dev/nix/nixcfg/${desktopName}-debug.log"

        echo "Starting ${name} at $(date)" >> "$LOGFILE"
        echo "Command: ${binary} --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode,WaylandWindowDecorations --disable-features=TranslateUI --disable-default-apps --new-window ${if useAppFlag then "--app=${url}" else "${url}"}" >> "$LOGFILE"
        echo "Predicted WM Class: ${predictedWMClass}" >> "$LOGFILE"

        # Run with standard flags
        ${binary} --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode,WaylandWindowDecorations --disable-features=TranslateUI --disable-default-apps --new-window ${if useAppFlag then "--app=${url}" else "${url}"} >> "$LOGFILE" 2>&1 &

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
        ${binary} --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode,WaylandWindowDecorations --disable-features=TranslateUI --disable-default-apps --new-window ${if useAppFlag then "--app=${url}" else "${url}"}
        ''}
      '';
      desktopItem = makeDesktopItem {
        type = "Application";
        name = desktopName;
        desktopName = name;
        startupWMClass = predictedWMClass;
        exec = "${scriptPath}/bin/${desktopName}"; # use the script to open the app - accounts for url encoding. which breaks due to the desktop file spec.
        icon = desktopName; # Use icon name for proper hicolor theme lookup
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
            ${if predictedWMClass != desktopName then ''
            # Also install icon with predicted WM class name for window manager matching
            cp $src "$out/share/icons/hicolor/${size}x${size}/apps/${predictedWMClass}.png"
            '' else ""}
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
