#!/usr/bin/env bash

set -euo pipefail
ICON_DIR="$HOME/.local/share/webapp-icons"
ERR_LOG="$ICON_DIR/error.log"
mkdir -p "$ICON_DIR"
> "$ERR_LOG"

# Use a modern browser User-Agent.
CURL_UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"

# Log errors with a timestamp.
log_error() {
  echo "[$(date)] ERROR: $*" >> "$ERR_LOG"
}

# Expect the apps list from the environment variable.
if [ -z "${WEBAPPS_ARRAY:-}" ]; then
  echo "WEBAPPS_ARRAY is not set. Exiting."
  exit 1
fi

readarray -t apps <<< "$WEBAPPS_ARRAY"
echo "Downloading icons for ${#apps[@]} apps"

for app in "${apps[@]}"; do
  IFS='|' read -r name url <<< "$app"
  safe_name=$(echo "$name" | tr ' ' '_')
  icon_file="$ICON_DIR/${safe_name}.ico"
  invalid_file="$ICON_DIR/${safe_name}.invalid"

  # Extract domain without protocol for Google S2
  base_domain=$(echo "$url" | sed -E 's|^https?://([^/]+).*|\1|')
  base_url="https://$base_domain"
  
  favicon_url="${base_url%/}/favicon.ico"
  echo "Downloading ${name} favicon from ${favicon_url}..."

  tmp_file=$(mktemp)
  header_file=$(mktemp)
  http_status=$(curl -L -s -A "$CURL_UA" -D "$header_file" -w "%{http_code}" "$favicon_url" -o "$tmp_file" || true)
  headers=$(head -n 5 "$header_file")
  rm "$header_file"

  if [ "$http_status" != "200" ]; then
    log_error "Primary download failed for ${name} from ${favicon_url} (HTTP status: $http_status, headers: $headers)"
    primary_fail=true
  else
    primary_fail=false
  fi

  mime_type=$(file --mime-type -b "$tmp_file" 2>/dev/null || true)
  if [ "$primary_fail" = false ] && echo "$mime_type" | grep -q 'image/'; then
    mv "$tmp_file" "$icon_file"
    echo "Downloaded ${name} icon to ${icon_file}"
    continue
  else
    rm -f "$tmp_file"
    echo "Primary attempt for ${name} did not yield a valid image (MIME: $mime_type). Trying fallback..."
  fi

  # Fallback 1: HTML extraction.
  tmp_page=$(mktemp)
  http_status=$(curl -L -s -A "$CURL_UA" -w "%{http_code}" "$url" -o "$tmp_page" || true)
  if [ "$http_status" != "200" ]; then
    log_error "Fallback failed: Unable to download HTML for ${name} from ${url} (HTTP status: $http_status)"
    rm -f "$tmp_page"
  else
    # Use non-failing grep with explicit error handling
    html_snippet=$(head -n 5 "$tmp_page")
    favicon_link=$( (grep -ioP '<link[^>]+rel=["'\''](?:shortcut\s+icon|icon|apple-touch-icon)["'\''][^>]*>' "$tmp_page" || :) \
      | (grep -ioP 'href=["'\'']\K[^"'\'' >]+' || :) | head -n 1)
    rm -f "$tmp_page"
    
    if [ -z "$favicon_link" ]; then
      log_error "Fallback failed: No favicon link found in HTML for ${name} from ${url}. HTML snippet: $html_snippet"
    else
      case "$favicon_link" in
        http* ) resolved_url="$favicon_link" ;;
        /*    ) resolved_url="${base_url}${favicon_link}" ;;
        *     ) resolved_url="${base_url}/${favicon_link}" ;;
      esac
      log_error "Fallback for ${name}: Trying extracted favicon URL: ${resolved_url}"
      tmp_file=$(mktemp)
      http_status=$(curl -L -s -A "$CURL_UA" -w "%{http_code}" "$resolved_url" -o "$tmp_file" || true)
      if [ "$http_status" != "200" ]; then
        log_error "Fallback failed for ${name} from ${resolved_url} (HTTP status: $http_status)"
        rm -f "$tmp_file"
      else
        mime_type=$(file --mime-type -b "$tmp_file" 2>/dev/null || true)
        if echo "$mime_type" | grep -q 'image/'; then
          mv "$tmp_file" "$icon_file"
          echo "Downloaded ${name} icon to ${icon_file} using fallback"
          continue
        else
          mv "$tmp_file" "$invalid_file"
          log_error "Fallback: Downloaded file for ${name} from ${resolved_url} is not a valid image (MIME: ${mime_type}). Saved as ${invalid_file}"
        fi
      fi
    fi
  fi

  # Fallback 2: Google S2
  fallback_google_url="https://www.google.com/s2/favicons?domain=${base_domain}&sz=128"
  echo "Trying Google S2 favicon service for ${name} from ${fallback_google_url}"
  tmp_file=$(mktemp)
  http_status=$(curl -L -s -A "$CURL_UA" -w "%{http_code}" "$fallback_google_url" -o "$tmp_file" || true)
  if [ "$http_status" != "200" ]; then
    log_error "Google S2 fallback failed for ${name} from ${fallback_google_url} (HTTP status: $http_status)"
    rm -f "$tmp_file"
    continue
  fi
  mime_type=$(file --mime-type -b "$tmp_file" 2>/dev/null || true)
  if echo "$mime_type" | grep -q 'image/'; then
    mv "$tmp_file" "$icon_file"
    echo "Downloaded ${name} icon to ${icon_file} using Google S2 fallback"
  else
    mv "$tmp_file" "$invalid_file"
    log_error "Google S2 fallback: Downloaded file for ${name} from ${fallback_google_url} is not a valid image (MIME: ${mime_type}). Saved as ${invalid_file}"
  fi
done
