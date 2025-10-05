#!/usr/bin/env bash

echo "save" | nc -W 1 -U /run/user/1000/ncspot/ncspot.sock
response=$(nc -W 1 -U /run/user/1000/ncspot/ncspot.sock)
title=$(echo "$response" | jq -r '.playable.title')
artist=$(echo "$response" | jq -r '.playable.artists[0]')
cover_url=$(echo "$response" | jq -r '.playable.cover_url')

# Download the album art
cover_path="/tmp/album_cover.jpg"
curl -s -o "$cover_path" "$cover_url"

# Send notification with album art
notify-send --app-name="NCSPOT" -i "$cover_path" "Song Saved" "$title - $artist"

exit 0