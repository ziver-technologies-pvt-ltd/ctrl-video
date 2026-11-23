# ctrl+video v2.0 Release Notes

**Theme:** "Control" — Precision streaming, format mastery, and tactile control.
**Active Release Branch:** `feature/v2-foundation`

---

## 🌟 Major Highlights in v2.0

### 1. In-App Video Preview Player (`media_kit` + libmpv)
- Embedded low-bandwidth video preview player running on native `libmpv` via `media_kit`.
- Smart stream selection resolving progressive <= 720p feeds for immediate preview while saving bandwidth.
- Codec support for AV1, VP9, H.264, AAC, and Opus.
- Handles separate adaptive video/audio stream pairing dynamically with custom user agent headers.
- Desktop keyboard controls: `Space` (Play/Pause), `J` / `L` (Seek -5s / +5s), `,` / `.` (Frame step back / forward).

### 2. Frame-Accurate Video Trimming
- Tactile interactive timeline scrubber with dual start and end adjustment handles.
- **Fast Mode (Keyframe cut)**: Instantaneous stream-copy cut at nearest keyframes (`--download-sections "*start-end"`).
- **Exact Mode (Frame-accurate)**: Boundary frame re-encoding (`--force-keyframes-at-cuts`) for sub-second precision.
- Quick playhead capture buttons: **Start at Playhead [I]** and **End at Playhead [O]**.
- Exact `HH:MM:SS.mmm` millisecond timecode inputs.
- SQLite persistence of clip boundaries (`trimStartMs`, `trimEndMs`, `trimMode`) in download history.

### 3. Advanced Stream & Codec Picker
- **Simple Mode**: One-click quality presets (1080p, 720p, 480p, Best, Audio Only) with container selection (MP4, MKV, WebM, MP3, FLAC, Opus).
- **Advanced Mode**: Detailed breakdown into *Video + Audio*, *Video Only*, and *Audio Only* streams.
- Shows resolution, container, exact video codec (e.g. `avc1.64002a`, `vp09.00.51`), audio codec (e.g. `opus`, `mp4a.40.2`), bitrate, and file size badges.

### 4. Tactile MD3 Monochrome + Warm Amber Design System
- 5-tier monochrome surface hierarchy (`surface-0` through `surface-4`) for depth without color distraction.
- **Warm Amber** (`#F59E0B`) signal accent applied exclusively to interactive states, active download progress, and playheads.
- Clean JetBrains Mono / Space Mono typography for technical metadata and timestamps.

### 5. Responsive Two-Pane Desktop Workspace
- Two-pane side-by-side workspace on standard and wide screens (≥ 900px):
  - **Left Pane**: In-app preview player and timeline trimming widget.
  - **Right Pane**: Video metadata, Simple/Advanced format selection, and download action.
- Graceful single-column collapse on narrow screens and laptop viewports.

### 6. Global Command Palette (`Ctrl+K` / `Cmd+K`)
- Instant keyboard-driven command palette accessible anywhere via `Ctrl+K` (or clicking the search badge in the top bar).
- Quick navigation between tabs: Download Workspace, Active Queue, Download History, Settings.
- Quick actions: "Paste from Clipboard & Fetch", "Resume All Paused Downloads", "Clear Completed Downloads".

---

## 🛠️ Verification & Test Results
- **Unit & Widget Tests**: 37 automated tests passing across format selection, database migration (v1 -> v2), preview stream resolution, trim parsing, error classification, and UI rendering.
- **Release Build Verification**: `flutter build linux --release` builds cleanly with zero compilation warnings or errors.
