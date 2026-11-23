# ctrl+video: Project Progress Tracker

| Version | Status | Active Branch | Last Updated |
|---|---|---|---|
| **v0.1-dev** | In Progress | `feature/initial-scaffold` | 2026-11-23 |

---

## Overall Progress Summary
- [x] **Project Planning**: Product name confirmed (`ctrl+video`), MVP plan updated.
- [x] **Dev Environment**: Fedora Linux desktop toolchain installed and verified (`flutter doctor` all checks green).
- [ ] **Milestone 1: Scaffold & Engine Foundation**: In Progress
- [ ] **Milestone 2: Metadata & Single Download Pipeline**: Pending
- [ ] **Milestone 3: Queue, Concurrency & Drift DB**: Pending
- [ ] **Milestone 4: Engine Update & Diagnostics**: Pending
- [ ] **Milestone 5: Multi-Platform Packaging & CI**: Pending

---

## Detailed Task Checklist

### Milestone 1: Scaffold, UI System & Engine Foundation
- [x] **Task 1.1**: Initialize Flutter project scaffold (`ctrl_video`) for linux, macos, windows.
- [x] **Task 1.2**: Define MD3 UI Guidelines ([docs/UI-GUIDELINES.md](file:///home/ceosiva/Ziver/ctrl+video/docs/UI-GUIDELINES.md)) & integrate brand logo asset into `lib/assets/` & `assets/branding/`.
- [ ] **Task 1.3**: Configure directory layout (`lib/app/theme`, `lib/features`, `lib/services`, `lib/data`, `lib/models`) and MD3 neutral theme data.
- [ ] **Task 1.4**: Add core dependencies to `pubspec.yaml` (`flutter_riverpod`, `drift`, `sqlite3_flutter_libs`, etc.).
- [ ] **Task 1.5**: Prepare asset directory structure for bundled engine binaries (`assets/engine/linux-x64/`, etc.).
- [ ] **Task 1.6**: Implement initial `ProcessRunner` and `PathResolver`.
- [ ] **Task 1.7**: Implement initial `EngineManager` seed logic to `~/.local/share/ctrl_video/engine/`.

### Milestone 2: URL Metadata & Single Download Pipeline
- [ ] **Task 2.1**: Implement `MetadataService` and `MediaInfo` model parsing.
- [ ] **Task 2.2**: Build URL validation and domain allowlist filter.
- [ ] **Task 2.3**: Build UI Home screen with URL input, clipboard detection, preview card.
- [ ] **Task 2.4**: Implement download runner with real-time stdout progress parser.
- [ ] **Task 2.5**: Implement `ErrorClassifier` with user-friendly error mappings.

### Milestone 3: Queue Management, History & Persistence
- [ ] **Task 3.1**: Setup Drift SQLite database and schema.
- [ ] **Task 3.2**: Implement `DownloadManager` queue with concurrency control.
- [ ] **Task 3.3**: Build Queue UI screen with cancel and retry actions.
- [ ] **Task 3.4**: Build History UI screen with file/folder openers.
- [ ] **Task 3.5**: Build Settings UI screen with folder picker and preferences.

### Milestone 4: Engine Auto-Update, Diagnostics & Self-Healing
- [ ] **Task 4.1**: Implement GitHub release fetch and SHA-256 verification in `EngineManager`.
- [ ] **Task 4.2**: Implement atomic swap and `.prev` rollback mechanism.
- [ ] **Task 4.3**: Integrate self-healing retry for outdated extractor errors.
- [ ] **Task 4.4**: Implement local file logging with diagnostic export.

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
