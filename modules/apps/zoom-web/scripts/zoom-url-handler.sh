#!/usr/bin/env bash

url="$1"

if [[ $url =~ ^zoom(mtg|us):// ]]; then
  confno=$(echo "$url" | sed -n 's/.*[?&]confno=\([^&]*\).*/\1/p')

  if [[ -n $confno ]]; then
    pwd=$(echo "$url" | sed -n 's/.*[?&]pwd=\([^&]*\).*/\1/p')

    if [[ -n $pwd ]]; then
      url_params="join/$confno?pwd=$pwd"
    else
      url_params="join/$confno"
    fi

    # Use the existing zoom web app with URL parameters
    exec /run/current-system/sw/bin/zoom "$url_params"
  fi
else
  # For non-meeting URLs or invalid URLs, just open the main zoom app
  exec /run/current-system/sw/bin/zoom "home/"
fi
