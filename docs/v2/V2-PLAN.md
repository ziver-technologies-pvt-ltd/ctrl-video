# ctrl+video: v2 Release Plan

Builds on v1.0 (Flutter desktop, bundled yt-dlp + ffmpeg, local-only downloads, Drift history, engine self-update).

**v2 theme: "Control."** Give users precise control over what they download (formats, trimming) and make the app feel premium.

---

## 1. v2 goals

1. **Multiple video and audio-only formats** with an advanced format picker.
2. **Preview player** on the Download page to play the fetched video.
3. **Frame-accurate trim**: drag handles plus exact time entry, with the start and end frames shown in the preview player.
4. **UI/UX redesign**: keep the monochrome identity, but make it richer, more tactile, and more polished.
5. A small set of **high-value extras** (section 8).

**Success criteria**
- User can preview a fetched video within ~3 seconds on a normal connection.
- Trimmed output matches the selected range (exact mode: within one frame; fast mode: snapped to the keyframe, and the UI says so).
- Every format shown in the picker downloads successfully, or fails with a clear message.
- v1 users upgrade without losing history or settings (Drift migration).

---

## 2. Feature 1: Multiple video and audio-only formats

### 2.1 What changes
v1 offers five presets. v2 keeps the presets as a **Simple** mode and adds an **Advanced** mode built from the real format list in `--dump-single-json`.

### 2.2 Simple mode (default)
Presets as in v1, plus a **container choice** (MP4 / MKV / WebM) and an **audio format choice**.

### 2.3 Advanced mode
Show the available formats grouped in tabs: **Video + Audio**, **Video only**, **Audio only**.

| Column | Source field |
|---|---|
| Resolution | `height` / `width` |
| FPS | `fps` |
| Codec | `vcodec` (H.264 / VP9 / AV1) |
| Container | `ext` |
| Dynamic range | `dynamic_range` (SDR/HDR) |
| Bitrate | `tbr` / `abr` |
| Size | `filesize` or `filesize_approx` (mark estimates with "≈") |

Behavior:
- Pick one video-only and one audio-only stream, and the app merges them with ffmpeg. Pick a combined format for a single stream.
- **Audio-only output formats:** MP3, M4A (AAC), Opus, FLAC, WAV, with a bitrate or quality choice (MP3/AAC). Lossless formats are converted from whatever the source provides, so label that honestly ("source is lossy").
- Sensible defaults and warnings: e.g. AV1/VP9 may not play in every media player, so show a "compatibility" hint. Offer an "H.264 compatible" toggle for max compatibility.
- Remember the user's last choice per platform.

### 2.4 Implementation notes
- Build the format string from selected `format_id`s (`-f <video_id>+<audio_id>`), and use `--merge-output-format` for the container.
- Audio extraction: `-x --audio-format <fmt> --audio-quality <q>`.
- Add a `FormatSelection` model (video id, audio id, container, audio codec, quality) rather than passing strings around, and keep a `toYtDlpArgs()` method with unit tests.
- Some platforms (Instagram, Facebook) expose few formats. Hide empty tabs and show a short note instead of an empty table.

---

## 3. Feature 2: Preview player on the Download page

### 3.1 Approach
Use a Flutter desktop video player based on **libmpv**, such as the `media_kit` package. It supports Windows, macOS and Linux, handles most codecs, and exposes mpv properties we need for precise seeking. Verify the current package state and desktop support before committing.

### 3.2 Where the stream comes from
- yt-dlp's JSON contains a direct URL and required `http_headers` for each format. Pass those headers to the player.
- For platforms that serve separate video and audio streams (YouTube above ~720p), load the video stream and attach the audio stream as an external audio track in mpv.
- For the preview, **prefer a lower-resolution stream (e.g. ≤720p)** so it starts fast and uses less data. The download format is independent of the preview format.
- Stream URLs are time-limited (they expire after a few hours). If playback fails with an HTTP error, re-fetch metadata and retry once.

### 3.3 UX
- Large player in the main pane, with play/pause, seek bar, volume, speed (0.5x–2x), fullscreen, and keyboard shortcuts (Space, ←/→ 5s, Shift+←/→ 1 min, `,` and `.` for frame-step).
- Shows a thumbnail until the user presses play, so metadata fetching stays fast and no bandwidth is used unless requested.
- Loading and error states: spinner, "Preview unavailable, you can still download" (never block downloading on preview failure).

### 3.4 Risks
- libmpv build licensing (LGPL vs GPL builds): check what the packaged binaries carry and update the in-app notices.
- Adds size to each installer. Measure and report it.
- Some formats (certain AV1/HDR streams) may stutter on older hardware, so fall back to a lower-resolution stream.

---

## 4. Feature 3: Trim (drag + exact time, frame-accurate preview)

### 4.1 UX design

```
┌───────────────── Preview player ──────────────────┐
│                  [ video frame ]                  │
│   ◀ Start frame        End frame ▶  (live)        │
├───────────────────────────────────────────────────┤
│ ▏▏▏▏▏▏▏▏▕██████████████████▏▏▏▏▏▏▏▏▏▏▏▏▏▏▏▏▏▏▏▏▏▏ │ ← timeline strip
│        ⟦start              end⟧                   │   with frame thumbnails
│ Start [00:01:12.480]  End [00:02:05.000]  Len 52.5s│
│ [Set start = playhead] [Set end = playhead]       │
│ Mode: ( ) Fast (keyframe)  (•) Exact (re-encode)  │
└───────────────────────────────────────────────────┘
```

- **Timeline strip** with draggable start and end handles, a draggable playhead, zoom (scroll or +/−) for fine control on long videos.
- **Exact time inputs:** `HH:MM:SS.mmm` fields for start and end, plus a frame-based nudge (±1 frame, ±1 second) using the video's FPS.
- **"Set start/end at playhead"** buttons and shortcuts (`I` and `O`, the standard in/out keys).
- **Frame preview of the boundaries:** while dragging or editing a handle, the main player seeks to that exact frame. Two small thumbnails ("Start frame" and "End frame") stay pinned beside the player so both boundaries are visible at once.
- **Loop-play the selection** so the user can verify the range before downloading.
- Show the **resulting duration** and an **estimated output size**.

### 4.2 Trim modes and honesty about accuracy

| Mode | How | Accuracy | Speed |
|---|---|---|---|
| **Fast** | Stream copy at cut points | Snaps to the nearest keyframe; start may begin slightly earlier | Fast |
| **Exact** | Re-encode around the cut points | Frame-accurate | Slower |

- The UI must say plainly when Fast mode will snap. Where possible, show the **actual keyframe** the cut will land on.
- Default to **Exact** for short clips, and suggest Fast for long ranges where speed matters.

### 4.3 Implementation

Two possible strategies. Prototype both and choose per mode:

**A. Section download via yt-dlp** (downloads only the requested range)
```
yt-dlp --download-sections "*00:01:12.480-00:02:05.000" \
       --force-keyframes-at-cuts ...
```
- `--force-keyframes-at-cuts` re-encodes at the cut points for exactness, but is slower.
- Saves bandwidth for long videos. Behavior varies by site and format (DASH vs progressive), so test on all three platforms.

**B. Full download + ffmpeg trim**
- Download the full file (or the chosen streams), then run ffmpeg with `-ss`/`-to` (stream copy for Fast, re-encode for Exact).
- More predictable, but wastes bandwidth and disk on long videos.

Recommendation: use **A** as the default for YouTube, and fall back to **B** if A fails or for platforms where section downloading is unreliable.

### 4.4 Frame-accurate seeking
- Configure the player for precise seeks (mpv's accurate/hr-seek behavior) while the user is adjusting handles. Use fast seeks while dragging for responsiveness, then an exact seek on release.
- Read FPS from the format JSON to convert between timecode and frame numbers. Handle variable frame rate gracefully (show time rather than frame index).
- Generate the timeline thumbnails lazily. Options: use the platform's storyboard images (YouTube provides `mhtml` storyboard formats in the format list), or sample frames with ffmpeg from the stream. Cache them per video.

### 4.5 Edge cases
- Start ≥ end, range outside the video, or range shorter than one frame: validate and disable Download.
- Live streams: disable trimming.
- Audio-only downloads: trim by time only (no frame preview).
- Cancel during a trim job: kill the ffmpeg and yt-dlp process tree and clean temp files.
- Store trim start and end in history so "re-download" reproduces the same clip.

---

## 5. Feature 4: UI/UX redesign

### 5.1 Direction
Keep **Material 3 as the component foundation** (accessibility, behaviors), but replace the generic "default MD3 look" with a distinct design language built around the keycap brand: **tactile, precise, dark-first, monochrome with one signal accent.**

### 5.2 Design principles
1. **Tactile:** buttons feel like keys: subtle depth, a press animation, short haptic-style motion.
2. **Precise:** monospaced timecodes, tight alignment, clear hierarchy.
3. **Calm:** monochrome surfaces; color only where it carries meaning.
4. **Fast:** keyboard-first, with visible shortcuts.

### 5.3 Color system (tokens, not hard-coded values)

Keep the neutral palette, but add structure:

| Token | Purpose |
|---|---|
| `surface-0…4` | Five tonal levels (app background → raised cards → dialogs) for depth without heavy shadows |
| `outline-subtle / strong` | Hairline borders (1px) to separate panes |
| `ink-primary / secondary / disabled` | Text hierarchy |
| `accent` | **One** signal color used sparingly: trim handles, active progress, primary action focus ring |
| `success / warning / danger` | Muted, desaturated status colors |

Notes:
- Suggest choosing the accent after testing a few options on the player and timeline (e.g. a warm amber or an electric blue). Keep the rest strictly neutral so the video content is the most colorful thing on screen.
- Verify contrast (WCAG AA) in both themes. Provide Light, Dark, and System.

### 5.4 Typography
- UI: a clean grotesque sans (e.g. Inter or similar).
- Timecodes, sizes, speeds and logs: a **monospace** (e.g. JetBrains Mono) so numbers don't jitter while updating.
- Define a type scale (display, title, body, label, mono) in one place.

### 5.5 Layout
- **Download page becomes a two-pane workspace:** left = player + trim timeline, right = metadata, format picker, output settings, Download button. Collapses to a single column on narrow windows.
- **Collapsible sidebar rail** with labels on wide windows, icons on narrow ones.
- **Queue as a persistent bottom or side tray** so downloads stay visible while you use other pages.
- Consistent card, spacing, and radius scale (4/8/12/16 grid).

### 5.6 Components and motion
- Custom keycap-style primary button, segmented controls for Simple/Advanced and Fast/Exact, chips for formats with codec badges.
- Progress: smooth animated bars with speed and ETA in mono type, plus a subtle completion animation.
- Page transitions and list animations: short (150–250 ms), eased, and respect the OS "reduce motion" setting.
- Empty states with an illustration or the keycap logo and one clear call to action.
- Skeleton loaders while metadata is fetching.
- Toasts or a snackbar for non-blocking events; dialogs only for destructive actions.

### 5.7 Keyboard-first (fits the "ctrl" name)
- Global shortcuts: paste and fetch, start download, open settings, switch pages, plus the player/trim keys above.
- A **command palette** (`Ctrl/⌘+K`): "Paste link", "Open downloads folder", "Check engine update", "Clear history".
- Show shortcut hints in tooltips and a shortcuts cheat sheet (`?`).

### 5.8 Accessibility
- Full keyboard navigation, visible focus rings, screen-reader labels on controls, scalable text, reduced-motion support, and AA contrast.

### 5.9 Deliverables
- A short **design spec** (tokens, type scale, spacing, component list) before coding.
- Mockups of three key screens (Download with trim, Queue, Settings) for review.
- Implement via a single `AppTheme` and a small shared component library, so screens don't hard-code styles.

---

## 6. Data and architecture changes

### 6.1 Drift schema migration (v1 → v2)
- `DownloadHistory`: add `videoFormatId`, `audioFormatId`, `container`, `audioCodec`, `trimStartMs`, `trimEndMs`, `trimMode`.
- `Settings`: add `theme`, `accentColor`, `lastFormatPrefs` (per platform), `previewQuality`.
- Write and test a migration that preserves existing rows. Test it against a real v1 database.

### 6.2 New services
| Service | Responsibility |
|---|---|
| `FormatService` | Parse formats, group/sort, build `FormatSelection`, produce args |
| `PreviewService` | Choose preview stream, manage player lifecycle, refresh expired URLs |
| `TrimService` | Validate ranges, build section/ffmpeg args, run trim jobs |
| `ThumbnailStripService` | Storyboard or ffmpeg-sampled frames, with cache |
| `ThemeService` | Tokens, theme mode, accent |

### 6.3 Testing additions
- Unit: `FormatSelection.toYtDlpArgs()`, timecode/frame conversions, trim validation, migration.
- Integration: trim accuracy tests (compare output duration/first frame against the request) for both modes.
- Test matrix: all three OSes × the three platforms for formats, preview, and trim.
- Performance: time-to-first-frame in the preview, UI frame rate while scrubbing, memory with long videos.

---

## 7. Roadmap (solo, ~8 weeks)

| Weeks | Milestone | Deliverable |
|---|---|---|
| 1 | **Design foundation** | Design spec, tokens, `AppTheme`, mockups; Drift migration written |
| 2 | **Formats** | Advanced picker, `FormatSelection`, audio formats, tests |
| 3–4 | **Preview player** | libmpv-based player, stream selection, external audio, expiry retry, keyboard controls |
| 5–6 | **Trim** | Timeline, handles, exact inputs, boundary frame previews, Fast/Exact modes, validation |
| 7 | **UI rollout** | Apply the redesign across all screens, command palette, motion, accessibility pass |
| 8 | **Hardening and beta** | Cross-OS testing, performance, installers, release notes |

Build order rationale: formats first (smallest and unblocks the rest), the player before trim (trim depends on it), and the visual redesign applied progressively so new screens are built in the new style from week 2.

---

## 8. Other useful upgrades to consider for v2

Grouped by value versus effort. Suggested picks are marked ★.

### Highest value
- ★ **Playlist and channel support** (select items, bulk queue, per-item formats).
- ★ **Persistent queue:** resume pending and interrupted downloads after an app restart.
- ★ **Subtitles:** download and embed (or save as .srt), with language choice and auto-generated captions as an option.
- ★ **Embed metadata and thumbnail** into the file (title, artist, cover art), especially useful for audio.
- ★ **Cookies from browser** (opt-in, local only) for age-restricted or members content the user is entitled to see. Needs a clear explanation and careful error messages.
- ★ **Desktop notifications** and a system tray icon (progress, completion, "open folder").

### Useful quality-of-life
- **Filename template editor** with live preview (`%(title)s`, `%(uploader)s`, date, resolution).
- **Speed limit, proxy, and retry settings.**
- **Duplicate detection:** warn if a link or file was already downloaded.
- **History upgrades:** filters (platform, status, date), sort, export to CSV.
- **Drag-and-drop a link** onto the window and a "watch clipboard" mode that auto-adds copied links.
- **SponsorBlock** options (skip or mark sponsor segments) where supported. Verify the current yt-dlp options.
- **Output presets:** "Phone compatible", "Small file", "Archive quality".

### Power features
- **Post-processing tools:** compress to a target size, export as GIF, extract a single frame, remove audio.
- **Hardware-accelerated re-encoding** for Exact trims and conversions (NVENC / VideoToolbox / VAAPI where available), with a software fallback.
- **Multiple clips from one video:** a list of trim ranges exported as separate files or concatenated.
- **Deep link scheme** (`ctrlvideo://download?url=...`) and a bookmarklet or small browser extension to send the current page to the app. This also supports your website-to-app flow.
- **App self-update** (not just the engine) with release notes.

### Platform and reach
- **Localization** (start with English plus two or three languages) and RTL-ready layouts.
- **Portable mode** (all data beside the executable).
- **Additional sites** beyond the current three, gated behind a "supported sites" list so expectations stay clear.
- **Opt-in diagnostics** (anonymous engine failure categories) to learn which updates fix breakages.

### Reliability
- **Engine channels** (stable and nightly) with one-click rollback.
- **Self-test on launch** (engine, ffmpeg, write permission) with a clear fix suggestion when something is missing.

---

## 9. Risks

| Risk | Mitigation |
|---|---|
| Trim accuracy differs between sites and formats | Offer both strategies, test on all three platforms, tell users when the cut snaps to a keyframe |
| Preview start-up slowness or stream expiry | Lower-resolution preview stream, lazy load, auto-refresh the URL once |
| Player library adds size and licensing obligations | Measure installer growth, review libmpv/ffmpeg licensing, update the notices screen |
| Redesign scope creep | Fix the token system and the component list first; limit v2 to three polished key screens plus consistent styling elsewhere |
| Migration breaks existing users' history | Test with real v1 databases; keep a backup copy before migrating |
| Bot checks and rate limits grow (YouTube in particular) | Keep the engine update pipeline healthy; make the cookies option available |
| Legal and terms exposure | Keep the user-responsibility language and takedown contact; get legal advice before wider promotion |

---

## 10. Definition of done (v2)

- [ ] Advanced format picker works for all three platforms, with tests for argument generation
- [ ] Preview plays on all three OSes, handles expired URLs, and never blocks downloading
- [ ] Trim works in Fast and Exact modes, boundary frames show in the player, and accuracy tests pass
- [ ] Redesign applied to every screen, with AA contrast, keyboard navigation, and reduced-motion support
- [ ] v1 → v2 migration verified on real data
- [ ] Selected extras (★ items) shipped or consciously deferred
- [ ] Installers built, signed where applicable, and tested on Windows, macOS, and Linux

---

## 11. Decisions to make before starting

1. **Accent color:** pure monochrome, or one accent (and which)?
2. **Player package:** confirm `media_kit` (or alternative) on all three desktop OSes with a quick spike in week 1.
3. **Trim default:** Exact or Fast?
4. **Which ★ extras make v2** and which move to v2.1?
5. **Cookies feature:** include now, or defer given the support load?
6. **Installer size budget** after adding the player.
