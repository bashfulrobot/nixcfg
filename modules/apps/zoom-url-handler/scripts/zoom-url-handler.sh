#!/usr/bin/env bash

url="$1"
web_url="https://app.zoom.us/wc/home"

if [[ $url =~ ^zoom(mtg|us):// ]]; then
  confno=$(echo "$url" | sed -n 's/.*[?&]confno=\([^&]*\).*/\1/p')

  if [[ -n $confno ]]; then
    pwd=$(echo "$url" | sed -n 's/.*[?&]pwd=\([^&]*\).*/\1/p')

    if [[ -n $pwd ]]; then
      web_url="https://app.zoom.us/wc/join/$confno?pwd=$pwd"
    else
      web_url="https://app.zoom.us/wc/join/$confno"
    fi
  fi
fi

# Open URL in chromium app mode with basic flags and custom class
exec /run/current-system/sw/bin/chromium --ozone-platform-hint=auto --force-dark-mode --enable-features=WebUIDarkMode,WaylandWindowDecorations --disable-features=TranslateUI --disable-default-apps --new-window --class=zoom-web-client --app="$web_url"