# ctrl+video: Milestones & Roadmap

This document outlines the detailed breakdown of milestones for building **ctrl+video** (v0.1 MVP).

---

## Milestone 1: Environment, Scaffolding, UI Foundations & Engine Seed
**Goal:** Initialize project structure, verify Flutter desktop on Linux, establish MD3 neutral UI design system & branding assets, bundle initial local engine assets (`yt-dlp` & `ffmpeg`), and create safe process execution layer.

- [ ] Flutter project scaffolding (`ctrl_video`, desktop platforms: Linux, macOS, Windows).
- [ ] Brand assets integration: Brand logo in `lib/assets/` & `assets/branding/`.
- [ ] UI Theme System: Material Design 3 theme configuration with neutral tonal palette (Light & Dark mode).
- [ ] Directory layout setup: `app/` (theme, navigation), `features/`, `services/`, `data/`, `models/`, `assets/engine/`.
- [ ] Core dependencies added: `flutter_riverpod`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `file_picker`, `open_filex`, `logger`.
- [ ] Linux engine setup: Bundle initial static `yt-dlp` and `ffmpeg` binaries for local testing.
- [ ] `ProcessRunner` implementation: safe argument list execution (no raw shell strings), working directory handling, process tree lifecycle.
- [ ] `EngineManager` (Phase 1): Locate bundled binaries and copy/seed them to user data directory (`~/.local/share/ctrl_video/engine/`).

---

## Milestone 2: URL Inspection & Single Download Pipeline
**Goal:** User inputs a URL, sees preview metadata (title, thumbnail, duration, format choices), and downloads an MP4/audio file with real-time progress.

- [ ] `MetadataService`: runs `yt-dlp --dump-single-json --no-playlist -- <URL>` and parses `MediaInfo` & `FormatOption`s.
- [ ] URL validation & allowlist verification (`youtube.com`, `youtu.be`, `instagram.com`, `facebook.com`, `fb.watch`).
- [ ] UI - Home Screen:
  - Clipboard auto-paste / URL input bar.
  - Media preview card (thumbnail, title, duration, author/uploader).
  - Format/Quality selector (Best, 1080p, 720p, 480p, Audio Only).
  - Action button: Start Download.
- [ ] Download execution:
  - Progress parsing from `stdout` (`--progress-template`).
  - Speed, percentage, ETA stream emission.
  - Video muxing via ffmpeg.
- [ ] Error classification (`ErrorClassifier`): basic parsing of stderr (network, unavailable, private, unsupported).

---

## Milestone 3: Queue Management, History & Persistence
**Goal:** Multi-download queue with concurrency control, cancellation/pause/resume, and Drift database persistence for settings and history.

- [ ] Drift SQLite Schema:
  - `DownloadHistory` table (url, platform, title, thumbnail, file path, format, size, status, errors, timestamps).
  - `Settings` table / key-value store (download dir, default quality, concurrency limit).
- [ ] `DownloadManager`:
  - Priority queue with maximum concurrent downloads (default: 2).
  - Status management: pending, downloading, completed, failed, cancelled.
  - Cancel & cleanup: kill process tree and clean partial files if cancelled.
- [ ] UI - Queue Screen:
  - Live progress bars, speed, ETA for active tasks.
  - Cancel & retry controls.
- [ ] UI - History Screen:
  - Searchable list of finished downloads.
  - "Open File", "Open Folder", "Delete Record", "Re-download" actions.
- [ ] UI - Settings Screen:
  - Pick default download directory with `file_picker`.
  - Concurrency selector & default quality selection.

---

## Milestone 4: Engine Auto-Update, Diagnostics & Self-Healing
**Goal:** Keep `yt-dlp` current without full app rebuilds, robust error recovery, and diagnostic logging.

- [ ] `EngineManager` (Phase 2):
  - Check GitHub releases API for latest `yt-dlp`.
  - Verify asset SHA-256 checksums.
  - Atomic swap with rollback to `yt-dlp.prev` on failed smoke test.
  - "Update Engine" button in Settings + 24h launch check.
- [ ] Self-healing retry on `engineOutdated` extractor error signatures.
- [ ] Local rotating file logger (`logger`) with "Copy Diagnostic Log" support in UI.

---

## Milestone 5: Cross-Platform Packaging, CI/CD & Final MVP Polish
**Goal:** Release-ready installers, automated build pipelines, and quality verification.

- [ ] Linux packaging: AppImage build workflow.
- [ ] Windows packaging: Inno Setup `.exe` workflow.
- [ ] macOS packaging: Universal `.dmg` with signing/notarization setup.
- [ ] GitHub Actions CI matrix: `flutter test`, build, binary bundling, release artifact creation.
- [ ] 30-link test suite verification (10 YouTube, 10 Instagram, 10 Facebook).
