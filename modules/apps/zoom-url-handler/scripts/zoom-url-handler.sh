#!/bin/bash

url="$1"
web_url="https://app.zoom.us/wc/home"

# Handle Google Calendar redirect URLs (e.g., https://www.google.com/url?q=https://zoom.us/j/123...)
if [[ $url =~ google\.com/url ]]; then
  # Extract the URL-encoded Zoom URL from the q= parameter
  encoded_zoom_url=$(echo "$url" | sed -n 's/.*[?&]q=\([^&]*\).*/\1/p')
  if [[ -n $encoded_zoom_url ]]; then
    # URL decode the extracted URL
    url=$(printf '%b' "${encoded_zoom_url//%/\\x}")
  fi
fi

# Handle zoom protocol URLs (zoommtg://, zoomus://, etc.)
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

# Handle HTTPS Zoom URLs
elif [[ $url =~ ^https?:// ]]; then
  # Extract domain to handle both zoom.us and custom domains (e.g., company.zoom.us)
  domain=$(echo "$url" | sed -n 's|^https\?://\([^/]*\).*|\1|p')

  # Handle Personal Meeting Room URLs: https://zoom.us/my/username or https://company.zoom.us/my/username
  if [[ $url =~ /my/([^/?]+) ]]; then
    username="${BASH_REMATCH[1]}"
    # Preserve query parameters if they exist
    params=$(echo "$url" | sed -n 's|^[^?]*\(?\.*\)|\1|p')
    web_url="https://$domain/wc/my/$username$params"

  # Handle standard join URLs: https://zoom.us/j/MEETINGID or https://zoom.us/j/MEETINGID?pwd=PASSWORD
  elif [[ $url =~ /j/([0-9]+) ]]; then
    meeting_id="${BASH_REMATCH[1]}"
    # Extract all query parameters (pwd, uname, tk, zak, etc.)
    params=$(echo "$url" | sed -n 's|^[^?]*\(?\.*\)|\1|p')

    if [[ -n $params ]]; then
      web_url="https://app.zoom.us/wc/join/$meeting_id$params"
    else
      web_url="https://app.zoom.us/wc/join/$meeting_id"
    fi

  # Handle web client URLs: https://zoom.us/wc/join/MEETINGID
  elif [[ $url =~ /wc/join/([0-9]+) ]]; then
    meeting_id="${BASH_REMATCH[1]}"
    params=$(echo "$url" | sed -n 's|^[^?]*\(?\.*\)|\1|p')

    # Already in web client format, but normalize to app.zoom.us
    if [[ -n $params ]]; then
      web_url="https://app.zoom.us/wc/join/$meeting_id$params"
    else
      web_url="https://app.zoom.us/wc/join/$meeting_id"
    fi
  else
    # If we can't parse it, try to use the URL as-is
    web_url="$url"
  fi
fi

exec zoom-launch-webapp "$web_url"