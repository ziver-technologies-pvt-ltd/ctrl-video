#!/usr/bin/env bash
set -e

TARGET_DIR="assets/engine/linux-x64"
mkdir -p "$TARGET_DIR"

echo "Fetching latest yt-dlp binary for Linux..."
curl -L -o "$TARGET_DIR/yt-dlp" "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"
chmod +x "$TARGET_DIR/yt-dlp"

echo "Fetching static ffmpeg binary for Linux..."
TMP_DIR=$(mktemp -d)
curl -L -o "$TMP_DIR/ffmpeg.tar.xz" "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz"
tar -xf "$TMP_DIR/ffmpeg.tar.xz" -C "$TMP_DIR"
cp "$TMP_DIR"/ffmpeg-*/bin/ffmpeg "$TARGET_DIR/ffmpeg"
chmod +x "$TARGET_DIR/ffmpeg"
rm -rf "$TMP_DIR"

echo "Engine binaries bundled successfully:"
ls -lh "$TARGET_DIR"
"$TARGET_DIR/yt-dlp" --version
"$TARGET_DIR/ffmpeg" -version | head -n 1
