#!/usr/bin/env bash
set -e

# Script to download standalone yt-dlp binary for bundling in assets/engine/linux-x64/
TARGET_DIR="assets/engine/linux-x64"
mkdir -p "$TARGET_DIR"

echo "Fetching latest yt-dlp binary for Linux..."
curl -L -o "$TARGET_DIR/yt-dlp" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"
chmod +x "$TARGET_DIR/yt-dlp"

echo "yt-dlp downloaded and verified: $($TARGET_DIR/yt-dlp --version)"
