# ctrl+video: v2 Task Progress Tracker

| Version | Status | Active Branch | Signal Accent | Player Engine |
|---|---|---|---|---|
| **v2.0-complete** | Ready for Review | `feature/v2-foundation` | Warm Amber (`0xFFF59E0B`) | `media_kit` (libmpv) |

---

## Overall v2 Progress Summary
- [x] **v2 Scope & Planning**: Documented in `docs/V2-PLAN.md` & `docs/V2-MILESTONES.md`.
- [x] **v2 Branching**: Created dedicated `feature/v2-foundation` branch.
- [x] **Milestone 2.1: Design System & Drift DB Migration**: Complete
- [x] **Milestone 2.2: Advanced Format & Codec Selection**: Complete
- [x] **Milestone 2.3: In-App Preview Player (`media_kit`)**: Complete
- [x] **Milestone 2.4: Frame-Accurate Video Trimming**: Complete
- [x] **Milestone 2.5: Two-Pane Workspace, Command Palette & Polish**: Complete

---

## Detailed Task Checklist

### Milestone 2.1: Design System Redesign & Database Migration
- [x] **Task 2.1.1**: Define tactile MD3 design tokens (`surface-0...4`, amber accent, mono typography) in `lib/app/theme.dart`.
- [x] **Task 2.1.2**: Update `DownloadRecords` table schema in `lib/data/database.dart` with trim and format columns.
- [x] **Task 2.1.3**: Implement Drift schema migration (`schemaVersion = 2`) with unit tests in `test/v2_database_migration_test.dart`.
- [x] **Task 2.1.4**: Re-run `build_runner` to update `database.g.dart`.

### Milestone 2.2: Advanced Format & Codec Selection Engine
- [x] **Task 2.2.1**: Implement `FormatSelection` data model with `toYtDlpArgs()` method.
- [x] **Task 2.2.2**: Build unit test suite for `FormatSelection` argument combinations (MP4, MKV, WebM, MP3, Opus, FLAC).
- [x] **Task 2.2.3**: Implement `FormatService` to categorize streams (`Video + Audio`, `Video Only`, `Audio Only`) with codec badges.
- [x] **Task 2.2.4**: Build UI segmented control and advanced format selection table (`AdvancedFormatPickerWidget`).

### Milestone 2.3: In-App Preview Player (`media_kit`)
- [x] **Task 2.3.1**: Add `media_kit`, `media_kit_video`, and `media_kit_libs_video` dependencies to `pubspec.yaml`.
- [x] **Task 2.3.2**: Initialize `MediaKit.ensureInitialized()` in `lib/main.dart`.
- [x] **Task 2.3.3**: Implement `PreviewService` (low-bandwidth stream selection <= 720p, HTTP headers, separate audio track attachment, URL refresh).
- [x] **Task 2.3.4**: Build desktop player widget (`DesktopPreviewPlayerWidget`) with custom controls and keyboard shortcuts (Space, seek, frame-step).

### Milestone 2.4: Frame-Accurate Video Trimming
- [x] **Task 2.4.1**: Build interactive timeline scrubber (`TimelineTrimWidget`) with draggable start/end handles and playhead.
- [x] **Task 2.4.2**: Implement `HH:MM:SS.mmm` exact time inputs and `I` / `O` shortcut keys.
- [x] **Task 2.4.3**: Implement `TrimService` and `TrimRange` handling Fast (keyframe copy) and Exact (re-encoded cut) download sections.
- [x] **Task 2.4.4**: Integrate trim arguments into `DownloadExecutionService` and persist trim parameters in SQLite.
- [x] **Task 2.4.5**: Add unit tests for trim range validation, timecode formatting, and section argument generation.

### Milestone 2.5: UI Workspace Redesign, Command Palette & Polish
- [x] **Task 2.5.1**: Build two-pane responsive workspace (player/trim on left, download options on right).
- [x] **Task 2.5.2**: Implement `Ctrl+K` / `Cmd+K` global command palette with fuzzy navigation, clipboard quick-paste, and queue actions.
- [x] **Task 2.5.3**: Accessibility and motion review (WCAG AA contrast, reduced motion, tactile monochrome surfaces).
- [x] **Task 2.5.4**: Run full acceptance test suite and release build verification (`flutter build linux --release`).

---

## Log of Key v2 Decisions
- **2026-11-24**: Created branch `feature/v2-foundation` to isolate v2 development.
- **2026-11-24**: Locked **`media_kit`** (libmpv) as the preview player engine for full codec support and separate audio track attachment.
- **2026-11-24**: Selected **Warm Amber** (`0xFFF59E0B`) as the single signal accent token over monochrome surfaces.
- **2026-11-24**: Defined trimming heuristics: Exact mode for short cuts (< 5 min), Fast mode (keyframe snap) recommended for long ranges.
- **2026-11-24**: Implemented `Ctrl+K` command palette with search-filtered actions and keyboard navigation.
