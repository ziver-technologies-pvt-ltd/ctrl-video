# ctrl+video: Project Progress Tracker

| Version | Status | Active Branch | Last Updated |
|---|---|---|---|
| **v0.1-dev** | In Progress | `feature/initial-scaffold` | 2026-11-23 |

---

## Overall Progress Summary
- [x] **Project Planning**: Product name confirmed (`ctrl+video`), MVP plan updated.
- [x] **Dev Environment**: Fedora Linux desktop toolchain installed and verified (`flutter doctor` all checks green).
- [x] **Milestone 1: Scaffold, UI System & Engine Foundation**: Completed
- [x] **Milestone 2: Metadata & Single Download Pipeline**: Completed
- [x] **Milestone 3: Queue Management, History & Persistence**: Completed
- [x] **Milestone 4: Engine Auto-Update, Diagnostics & Self-Healing**: Completed
- [ ] **Milestone 5: Multi-Platform Packaging & CI**: Pending

---

## Detailed Task Checklist

### Milestone 1: Scaffold, UI System & Engine Foundation
- [x] **Task 1.1**: Initialize Flutter project scaffold (`ctrl_video`) for linux, macos, windows.
- [x] **Task 1.2**: Define MD3 UI Guidelines ([docs/UI-GUIDELINES.md](file:///home/ceosiva/Ziver/ctrl+video/docs/UI-GUIDELINES.md)) & integrate brand logo asset into `lib/assets/` & `assets/branding/`.
- [x] **Task 1.3**: Configure directory layout (`lib/app/theme`, `lib/features`, `lib/services`, `lib/data`, `lib/models`) and MD3 neutral theme data.
- [x] **Task 1.4**: Add core dependencies to `pubspec.yaml` (`flutter_riverpod`, `drift`, `sqlite3_flutter_libs`, `path_provider`, etc.).
- [x] **Task 1.5**: Prepare asset directory structure for bundled engine binaries (`assets/engine/linux-x64/`, etc.).
- [x] **Task 1.6**: Implement initial `ProcessRunner` and `PathResolver`.
- [x] **Task 1.7**: Implement initial `EngineManager` seed logic to `~/.local/share/ctrl_video/engine/`.
- [x] **Task 1.8**: Create desktop shell navigation rail (Download, Queue, History, Settings) with live engine status bar.

### Milestone 2: URL Metadata & Single Download Pipeline
- [x] **Task 2.1**: Implement `MetadataService` and `MediaInfo` model parsing.
- [x] **Task 2.2**: Build URL validation and domain allowlist filter (YouTube, Instagram, Facebook).
- [x] **Task 2.3**: Build UI Download screen with URL input, clipboard auto-detection, and media preview card.
- [x] **Task 2.4**: Implement download execution with real-time stdout progress parser (`--progress-template`).
- [x] **Task 2.5**: Implement `ErrorClassifier` with user-friendly error mappings for all major failure modes.
- [x] **Task 2.6**: Unit and widget tests for URL validation, error classification, and download screen.

### Milestone 3: Queue Management, History & Persistence
- [x] **Task 3.1**: Create Drift SQLite schema: `DownloadHistory` table and `Settings` table (`lib/data/database.dart`).
- [x] **Task 3.2**: Run code generation with `build_runner` to produce `database.g.dart`.
- [x] **Task 3.3**: Implement `DownloadManager` service with priority queue, max concurrency (2 items), cancellation, retry, and history persistence.
- [x] **Task 3.4**: Build Queue UI screen (`lib/features/queue/queue_screen.dart`) displaying active progress, waiting tasks, and cancel/retry actions.
- [x] **Task 3.5**: Build History UI screen (`lib/features/history/history_screen.dart`) with search, "Open File", "Open Folder", and "Delete".
- [x] **Task 3.6**: Build Settings UI screen (`lib/features/settings/settings_screen.dart`) with folder picker, default quality selection, and engine status check.
- [x] **Task 3.7**: Unit and widget tests for database operations and queue lifecycle.

### Milestone 4: Engine Auto-Update, Diagnostics & Self-Healing
- [x] **Task 4.1**: Implement `EngineUpdateService` to fetch latest `yt-dlp` release info from GitHub API and check platform SHA-256 hashes.
- [x] **Task 4.2**: Implement atomic download, validation, and swap in `EngineManager` with `.prev` rollback on smoke test failure.
- [x] **Task 4.3**: Integrate self-healing retry in `DownloadManager` when an outdated engine signature is classified.
- [x] **Task 4.4**: Implement local rotating file logger (`lib/services/app_logger.dart`) with diagnostic info export to clipboard.
- [x] **Task 4.5**: Enhance Settings UI with live update progress, version comparison, and diagnostic export.
- [x] **Task 4.6**: Unit tests for update verification, checksum calculation, and rollback logic.

### Milestone 5: Packaging & CI/CD
- [ ] **Task 5.1**: GitHub Actions workflow for multi-OS build matrix.
- [ ] **Task 5.2**: Linux AppImage packaging.
- [ ] **Task 5.3**: Windows Inno Setup packaging.
- [ ] **Task 5.4**: macOS DMG packaging.
- [ ] **Task 5.5**: 30-link integration test verification.

---

## Log of Key Changes & Decisions
- **2026-11-23**: Confirmed product name **ctrl+video** (package name `ctrl_video`).
- **2026-11-23**: Chose bundled initial engine binaries in installer/assets seeded to per-user data folder on first run.
- **2026-11-23**: Verified Fedora Linux desktop prerequisites (`clang`, `cmake`, `ninja`, `gtk3-devel`).
