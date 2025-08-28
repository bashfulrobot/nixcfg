#!/usr/bin/env bash
niri msg windows | ${pkgs.jq} -r '.[] | "\(.id) \(.app_id // .title)"' | fuzzel --dmenu | cut -d' ' -f1 | xargs -r niri msg window focus --id