#!/bin/bash

BROWSER_BINARY="/run/current-system/sw/bin/chromium"

exec "$BROWSER_BINARY" \
  --ozone-platform-hint=auto \
  --force-dark-mode \
  --enable-features=WebUIDarkMode,WaylandWindowDecorations \
  --disable-features=TranslateUI \
  --disable-default-apps \
  --new-window \
  --app="$1" "${@:2}"