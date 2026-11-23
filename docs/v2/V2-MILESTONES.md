# ctrl+video: v2 Milestones & Technical Roadmap

Theme: **"Control."** Precise format selection, in-app stream preview player, frame-accurate trimming, and rich tactile MD3 redesign with a warm amber signal accent.

---

## Milestone 2.1: Design System Redesign & Database Migration
**Goal:** Establish the refined tactile design tokens, monochrome + amber palette, and upgrade the Drift SQLite schema from v1 to v2 without data loss.

- [ ] **Design Tokens & Theme System**:
  - Implement 5-level surface tokens (`surface-0` to `surface-4`) in `lib/app/theme.dart`.
  - Add signal accent token: Warm Amber (`0xFFF59E0B` / `0xFFFFB020`).
  - Configure JetBrains Mono / Roboto Mono monospace scale for timecodes, bitrates, speed, and ETA.
  - Implement tactile keycap button styling (subtle press animation, depth borders).
- [ ] **Drift SQLite Migration (v1 → v2)**:
  - Update `DownloadRecords` table schema with new columns:
    - `videoFormatId`, `audioFormatId`, `container`, `audioCodec`, `trimStartMs`, `trimEndMs`, `trimMode`.
  - Add `Settings` keys: `themeMode`, `accentColor`, `previewQuality`, `lastFormatPrefs`.
  - Implement and test Drift schema migration step (`schemaVersion = 2`) with in-memory automated test.

---

## Milestone 2.2: Advanced Format & Codec Selection Engine
**Goal:** Transform the format picker into an advanced stream inspector and multi-stream merger with unit-tested argument generation.

- [ ] **Data Modeling**:
  - Implement `FormatSelection` model encapsulating video stream ID, audio stream ID, target container (MP4, MKV, WebM), audio output format (MP3, M4A, Opus, FLAC, WAV), and quality settings.
  - Implement `toYtDlpArgs()` on `FormatSelection` with comprehensive unit tests.
- [ ] **FormatService**:
  - Categorize streams into tabs: `Video + Audio` (combined), `Video Only`, and `Audio Only`.
  - Extract and display: resolution, FPS, video codec (H.264, VP9, AV1), dynamic range (SDR/HDR), bitrate, and approximate file size.
  - Codec compatibility indicators (e.g. H.264 compatibility tag vs. AV1 high efficiency).
- [ ] **UI - Format Selector**:
  - Segmented control toggle: **Simple Mode** (v1 presets + container picker) vs. **Advanced Mode** (granular stream inspector table).
  - Platform-adaptive display: Hide empty tabs for platforms with limited formats (Instagram/Facebook).

---

## Milestone 2.3: In-App Preview Player (`media_kit`)
**Goal:** Enable responsive, in-app stream playback on the Download page using `media_kit` (libmpv).

- [ ] **Player Integration**:
  - Add `media_kit`, `media_kit_video`, and platform native libraries to `pubspec.yaml`.
  - Initialize `MediaKit.ensureInitialized()` in `main.dart`.
- [ ] **PreviewService**:
  - Select lightweight stream (`≤720p`) with HTTP headers (`User-Agent`, `Referer`) extracted from yt-dlp metadata.
  - Handle separate audio attachment where video and audio are split.
  - Handle stream expiration with automatic one-time metadata refresh on HTTP 403/410.
  - Graceful fallback: Never block downloading if preview fails.
- [ ] **UI - Desktop Player Component**:
  - Integrated into the left pane of the Download workspace.
  - Controls: Play/pause, seek scrubber, volume, playback speed (0.5x – 2.0x), fullscreen toggle.
  - Desktop keyboard shortcuts: Space (play/pause), Left/Right (seek ±5s), Shift+Left/Right (seek ±1m), `,` / `.` (frame step).

---

## Milestone 2.4: Frame-Accurate Video Trimming
**Goal:** Allow users to set start/end points with interactive drag handles, exact time inputs, and boundary frame previews.

- [ ] **Timeline Strip Component**:
  - Draggable start and end trim handles with warm amber focus rings.
  - Draggable playhead scrubbing through video duration.
  - Lazy frame thumbnail generation or storyboard image sampling (`ThumbnailStripService`).
- [ ] **Timecode & Frame Input Controls**:
  - Exact `HH:MM:SS.mmm` text inputs for start and end times.
  - Quick action buttons: "Set Start at Playhead" (`I` key) and "Set End at Playhead" (`O` key).
  - Nudge buttons: ±1 frame and ±1 second.
  - Pinned start frame and end frame thumbnails beside the player.
- [ ] **Trim Execution Engine (`TrimService`)**:
  - **Fast Mode**: Snaps cut to nearest keyframe using stream copy (instantaneous).
  - **Exact Mode**: Re-encodes boundary frames around cuts (`--download-sections` with `--force-keyframes-at-cuts`) for 100% frame accuracy.
  - Default selection heuristic: Exact mode for clips < 5 minutes; Fast mode for long clips.
  - Boundary validation: Disallow `start >= end` or zero-duration cuts.
  - Pass trim parameters to SQLite download history for exact re-download capability.

---

## Milestone 2.5: UI Workspace Redesign, Command Palette & Polish
**Goal:** Complete the two-pane workspace rollout, global command palette, and release hardening.

- [ ] **Two-Pane Workspace**:
  - Left pane: Preview player + Trim timeline strip.
  - Right pane: Video metadata card, format selector (Simple/Advanced), trim settings, and Download button.
  - Responsive collapse to single column on narrow desktop windows (< 900px).
- [ ] **Command Palette (`Ctrl+K` / `Cmd+K`)**:
  - Quick commands: Paste & Fetch, Toggle Theme, Open Downloads Folder, Update Engine, Clear History, View Shortcuts (`?`).
- [ ] **Accessibility & Motion Pass**:
  - Verify WCAG AA contrast across monochrome + amber tokens.
  - Support OS "Reduced Motion" settings for page transitions.
- [ ] **Acceptance & Cross-Platform Hardening**:
  - 30-link test suite verification for formats and trimming across Linux, Windows, and macOS.
  - Installer builds and release notes preparation for v2.0.
