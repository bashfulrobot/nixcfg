#!/usr/bin/env bash

# Screenshot OCR - extract text from latest screenshot
# Based on your original sys/scripts/screenshot-ocr.sh

XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
save_dir="${XDG_PICTURES_DIR}/Screenshots"
tmpdir="/tmp/screenshot-ocr"

mkdir -p "$save_dir"
mkdir -p "$tmpdir"

# Ensure required binaries
command -v tesseract >/dev/null 2>&1 || { echo "tesseract not found"; exit 1; }
command -v wl-copy >/dev/null 2>&1 || { echo "wl-copy not found"; exit 1; }
command -v notify-send >/dev/null 2>&1 || { echo "notify-send not found"; exit 1; }

# Get the most recent screenshot (like your original script)
recent_screenshot=$(ls -t "$save_dir"/*.png 2>/dev/null | head -n1)

# Check if a file was found
if [[ -z "$recent_screenshot" ]]; then
    notify-send -a "Screenshot OCR" -u critical "No screenshots found" "No screenshot files found in $save_dir"
    exit 1
fi

# Show processing notification
notify-send -a "Screenshot OCR" -t 2000 "Processing..." "Extracting text from $(basename "$recent_screenshot")..."

# Process the screenshot with Tesseract
tesseract "$recent_screenshot" "$tmpdir/output" 2>/dev/null

# Check if OCR was successful
if [ ! -f "$tmpdir/output.txt" ]; then
    notify-send -a "Screenshot OCR" -u critical "OCR failed" "Could not extract text from image"
    exit 1
fi

# Copy the result to clipboard (clean up non-ASCII characters like your original)
cat "$tmpdir/output.txt" | \
    tr -cd '\11\12\15\40-\176' | \
    grep . | \
    perl -pe 'chomp if eof' | \
    wl-copy

# Get extracted text for notification
extracted_text=$(cat "$tmpdir/output.txt" | head -c 100)
if [ -z "$extracted_text" ]; then
    extracted_text="No text detected"
fi

# Show success notification
notify-send -a "Screenshot OCR" -t 5000 \
    "Text Extracted" \
    "📋 Copied to clipboard\n\nExtracted: ${extracted_text}..."

# Clean up temporary files
rm -rf "$tmpdir"