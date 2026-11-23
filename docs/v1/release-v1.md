# ctrl+video: Release v1.0 (MVP) Feature & Functionality Specification

This document details the functional specifications, capabilities, and system behaviors delivered in **Release v1.0** of **ctrl+video**.

---

## 1. Executive Summary

**ctrl+video** v1.0 is a desktop-native video and audio downloading tool for Linux, Windows, and macOS. The application is built with Flutter and adheres to Google's Material Design 3 (MD3) guidelines with a bespoke monochrome/neutral color scheme matching its tactile keycap branding.

Downloads are executed **100% locally on the user's IP address** via bundled `yt-dlp` and `ffmpeg` sidecars, guaranteeing complete privacy and eliminating intermediate proxy bottlenecks.

---

## 2. Platform & OS Support

| Target OS | Minimum Version | Distribution Artifact |
|---|---|---|
| **Linux** | Fedora 38+, Ubuntu 22.04 LTS+ (x64) | Standalone release bundle / AppImage |
| **Windows** | Windows 10 / Windows 11 (x64) | Inno Setup installer (`.exe`) / portable zip |
| **macOS** | macOS 12 Monterey+ (Apple Silicon & Intel) | Universal `.dmg` / `.app` bundle |

---

## 3. Core Features & Functional Details

### 3.1. Media Input & URL Inspection
- **Clipboard Integration**: Automatically scans the system clipboard on launch and window focus. If a supported URL is detected, it auto-fills the input bar.
- **Domain Whitelisting**: Strict URL parser ensuring only supported platform links are accepted:
  - **YouTube**: Standard videos (`youtube.com/watch?v=...`), Short links (`youtu.be/...`), and YouTube Shorts (`youtube.com/shorts/...`).
  - **Instagram**: Public Reels (`instagram.com/reel/...`) and Public Posts (`instagram.com/p/...`).
  - **Facebook**: Public Videos (`facebook.com/watch/...`) and Reels (`fb.watch/...`).
- **Metadata Extraction**:
  - Executes `yt-dlp --dump-single-json --no-playlist` securely.
  - Extracts and renders: video thumbnail, title, author/uploader, duration, and supported format resolutions.

### 3.2. Format & Quality Selection
The application exposes a clean dropdown selector mapped directly to optimal platform formats:
- **Best Available (Auto)**: Automatically merges the highest bitrate video and audio streams into an MP4 container.
- **1080p Full HD (MP4)**: `bv*[height<=1080]+ba/b[height<=1080]`
- **720p HD (MP4)**: `bv*[height<=720]+ba/b[height<=720]`
- **480p SD (MP4)**: `bv*[height<=480]+ba/b[height<=480]`
- **Audio Only (MP3)**: Extracts and converts audio stream to high-quality MP3 (`-x --audio-format mp3 --audio-quality 0`).

### 3.3. Download Execution & Real-Time Metrics
- **Real-Time Progress Parser**: Captures structured stdout lines using `--progress-template` to extract:
  - Download percentage (`0.0% – 100.0%`).
  - Download speed (e.g., `4.8 MB/s`).
  - Estimated Time of Arrival (ETA, e.g., `00:42`).
- **Process Lifecycle Management**: Safe process spawning using argument arrays. Allows immediate cancellation with process tree termination and partial file cleanup.
- **Accurate File Path Resolution**: Emits `--print after_move:filepath` to capture the final post-muxing filename on disk.

### 3.4. Concurrency & Queue Management
- **Managed Priority Queue**: Allows users to enqueue multiple downloads simultaneously.
- **Configurable Concurrency**: Defaults to 2 simultaneous downloads; user-configurable from 1 to 4 in Settings.
- **Task Controls**: Cancel active downloads, retry failed or cancelled downloads, and dismiss completed tasks.
- **Navigation Badge**: Displays real-time badge count of active downloads on the Queue navigation icon.

### 3.5. Persistence & Download History
- **Drift SQLite Storage**: Automatically records every download attempt in a local database:
  - Title, URL, platform, format label, thumbnail URL.
  - Final local file path on disk.
  - Status (`completed`, `failed`, `cancelled`), error code, and timestamps.
- **History Actions**:
  - Live search bar filtering history by title or platform.
  - **Open File**: Launches the video in the user's default media player (VLC, mpv, etc.).
  - **Open Folder**: Opens the containing folder directly in the system file manager (Nautilus, Dolphin, Explorer, Finder) with fallback to `xdg-open`.
  - **Delete Record** & **Clear All**: Remove records from history.

### 3.6. Engine Self-Healing & Auto-Update
- **Per-User Engine Storage**: Binaries reside in `~/.local/share/com.ctrlvideo.ctrl_video/ctrl_video/engine/` rather than root directories, enabling updates without administrator rights.
- **GitHub Release Sync**: Fetches the latest release metadata and downloads matching platform binaries from the official `yt-dlp` repository.
- **Cryptographic Verification**: Downloads `SHA2-256SUMS` and validates the downloaded binary's SHA-256 hash before installation.
- **Atomic Swap & Rollback**:
  - Writes to a temporary file (`yt-dlp.tmp`).
  - Sets executable permissions and performs a smoke test (`--version`).
  - Backs up the active binary to `yt-dlp.prev` and renames the new binary.
  - Automatically rolls back to `yt-dlp.prev` if the smoke test or replacement fails.

### 3.7. Diagnostics & Error Handling
- **Human-Friendly Error Classifier**: Translates cryptic stderr outputs into clear messages and actionable advice:
  - `unsupportedUrl`, `privateVideo`, `unavailable`, `geoBlocked`, `rateLimited`, `engineOutdated`, `network`, `disk`, and `unknown`.
- **Local Diagnostic File Logger**: Writes timestamped logs to a rotating log file (`app.log`, max 2MB with rollover to `app.log.old`).
- **One-Click Diagnostic Export**: Settings screen provides a "Copy Logs" button copying environment details and recent logs to the clipboard.

---

## 4. UI/UX Design System

- **Design Language**: Material Design 3 (MD3).
- **Navigation**: Desktop `NavigationRail` pinned to the left edge with keycap logo header and 4 primary views:
  1. **Download**: Input bar, fetch button, preview card, format dropdown, and live progress bar.
  2. **Queue**: Active task list with speed/ETA metrics and cancel/retry buttons.
  3. **History**: Searchable list with media player and folder launcher buttons.
  4. **Settings**: Directory picker, concurrency selector, engine update panel, and diagnostic logger.
- **Color Palette**: High-contrast, tactile monochrome aesthetic (deep graphite `0xFF1E1E1E` and crisp white `0xFFFFFFFF`) across both Light and Dark themes.

---

## 5. Security & Privacy Guarantees

1. **Zero External Media Traffic**: No user data, URLs, or downloaded videos are sent to or stored on any external server.
2. **Safe Command Spawning**: Commands are invoked using `dart:io` `Process.start` with parameter lists (`runInShell: false`). Shell strings are never constructed or executed.
3. **Flag Injection Protection**: User URLs are passed after the `--` argument delimiter to prevent parameter hijacking.
