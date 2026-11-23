#!/usr/bin/env bash
set -e

# Downloads static yt-dlp binaries for all supported desktop targets
echo "=== Bundling cross-platform engine binaries ==="

# 1. Linux x64
mkdir -p assets/engine/linux-x64
echo "Fetching Linux x64 binary..."
curl -L -s -o assets/engine/linux-x64/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
chmod +x assets/engine/linux-x64/yt-dlp

# 2. Windows x64
mkdir -p assets/engine/windows-x64
echo "Fetching Windows x64 binary..."
curl -L -s -o assets/engine/windows-x64/yt-dlp.exe https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe

# 3. macOS (Universal / arm64 / x64)
mkdir -p assets/engine/macos-arm64 assets/engine/macos-x64
echo "Fetching macOS binary..."
curl -L -s -o assets/engine/macos-arm64/yt-dlp_macos https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos
chmod +x assets/engine/macos-arm64/yt-dlp_macos
cp assets/engine/macos-arm64/yt-dlp_macos assets/engine/macos-x64/yt-dlp_macos

echo "All engine binaries bundled successfully in assets/engine/"
ls -lh assets/engine/*
