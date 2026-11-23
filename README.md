# ctrl+video

<p align="center">
  <img src="lib/assets/logo.png" width="128" height="128" alt="ctrl+video logo" />
</p>

<p align="center">
  <b>A modern, cross-platform desktop video downloader powered by Flutter, yt-dlp, and ffmpeg.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-blue?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/Flutter-3.50.0-02569B?style=flat-square&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Design-Material%20Design%203-4285F4?style=flat-square" alt="Design" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
</p>

---

## 💡 About ctrl+video

**ctrl+video** is a clean, desktop-first video downloading client designed around privacy and performance. Unlike traditional online downloaders that route media through remote web servers, **ctrl+video runs 100% locally on your machine and IP**. 

It uses standalone, self-healing sidecar engines (**yt-dlp** and **ffmpeg**) to extract and download high-definition media directly from public platforms without requiring third-party proxies, accounts, or telemetry.

---

## ✨ Features

- **Multi-Platform Support**: Works seamlessly on YouTube (standard videos, Shorts), Instagram (public Reels, posts), and Facebook (public videos, Reels).
- **Clipboard Auto-Detection**: Automatically detects video links copied to your clipboard as soon as you open the app.
- **Rich Media Preview**: View video thumbnail, title, uploader/channel, and duration before starting the download.
- **Flexible Quality & Formats**:
  - **Video (MP4)**: Best Available, 1080p Full HD, 720p HD, 480p SD.
  - **Audio Only (MP3)**: High-quality extracted audio.
- **Concurrency & Download Queue**: Download queue supporting simultaneous downloads (configurable concurrency up to 4 tasks), with live progress bars, speed metrics, and ETA counters.
- **Local Persistence & History**: Powered by an embedded Drift (SQLite) database. View past downloads, search by title or platform, and launch files or directories with one click.
- **Self-Healing Engine Lifecycle**:
  - Automatically checks for latest `yt-dlp` updates from GitHub.
  - Verifies cryptographic SHA-256 checksums before applying updates.
  - Performs atomic swaps with automatic rollback to the previous version (`.prev`) if a smoke test fails.
- **Material Design 3 (MD3)**: Clean, high-contrast monochrome/neutral theme inspired by tactile keycap aesthetics, with full Light and Dark mode support.

---

## 🏗️ Architecture & Tech Stack

```
ctrl_video/
├─ lib/
│  ├─ main.dart                 # Application entry & navigation rail
│  ├─ app/                      # MD3 themes (neutral Light & Dark)
│  ├─ features/
│  │  ├─ home/                  # URL input, preview card, quality picker
│  │  ├─ queue/                 # Live active & queued downloads
│  │  ├─ history/               # Searchable local SQLite download history
│  │  └─ settings/              # Download directory picker & engine updates
│  ├─ services/
│  │  ├─ engine_manager.dart    # Binary lifecycle, seeding, and atomic rollback
│  │  ├─ engine_update_service  # GitHub releases fetch & SHA-256 validation
│  │  ├─ metadata_service.dart  # URL validation & metadata extraction
│  │  ├─ download_execution.dart# stdout progress parser & ffmpeg muxer
│  │  ├─ download_manager.dart  # Concurrency queue & SQLite synchronization
│  │  ├─ error_classifier.dart  # Human-friendly error translation
│  │  └─ path_resolver.dart     # OS-specific per-user app data directories
│  └─ data/                     # Drift SQLite database & schemas
├─ assets/branding/             # High-resolution brand assets
├─ assets/engine/               # Bundled sidecar binaries (yt-dlp, ffmpeg)
├─ docs/                        # Specifications, milestones, and test suite
└─ test/                        # Unit and widget test suite
```

- **Framework**: Flutter Desktop (Linux, macOS, Windows)
- **State Management**: Flutter Riverpod
- **Database**: Drift (SQLite) with background query execution
- **Process Management**: `dart:io` `Process.start` using secure argument lists (no shell injection)
- **Sidecar Engines**: `yt-dlp` (standalone executable) + `ffmpeg` (static build)

---

## 🚀 Getting Started

### Prerequisites

#### Linux (Fedora / RHEL)
```bash
sudo dnf install clang cmake ninja-build gtk3-devel mesa-libGL-devel
```

#### Linux (Ubuntu / Debian)
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

### Installation & Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/ctrl-video.git
   cd ctrl-video
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Fetch local engine binaries:**
   ```bash
   ./scripts/fetch_linux_engine.sh
   ```

4. **Run tests:**
   ```bash
   flutter test
   ```

5. **Run in development mode:**
   ```bash
   flutter run -d linux
   ```

6. **Build release package:**
   ```bash
   flutter build linux --release
   ```

---

## 🔒 Security & Privacy

- **No Remote Proxies**: Video links and media bytes never touch external servers or cloud middle-boxes.
- **Direct Local Execution**: Process calls strictly use safe argument lists (`runInShell: false`) with `--` argument delimiters, preventing arbitrary command injection.
- **Domain Allowlisting**: Only verified target domains (`youtube.com`, `youtu.be`, `instagram.com`, `facebook.com`, `fb.watch`) are accepted for extraction.

---

## 📄 License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
