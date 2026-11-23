# ctrl+video: MVP Plan

A cross-platform desktop app (Flutter) that downloads videos using the **user's own machine and IP**, by running yt-dlp and ffmpeg as bundled sidecar processes. A small static website (ctrlvideo.org) serves as the landing and download page.

---

## 1. MVP goal

> A user installs the app, pastes a public video link (YouTube, Instagram, or Facebook), picks a quality, and gets a working file on their disk. The engine can update itself when a platform breaks it.

**Success criteria**
- Paste link, see title/thumbnail/formats, download works on Windows, macOS, and Linux.
- At least 90% success on a test set of 30 public links (10 per platform) at release.
- The engine (yt-dlp) updates without an app reinstall.
- No server handles any media or user links.

---

## 2. Scope

### In scope (v0.1)
| Area | Included |
|---|---|
| Platforms | YouTube (videos, Shorts), Instagram (public posts/reels), Facebook (public videos/reels) |
| Input | Paste a single URL, with auto-detect from clipboard |
| Output | Video (MP4), audio only (MP3/M4A) |
| Quality | Picker built from yt-dlp's format list (Best, 1080p, 720p, 480p, Audio) |
| Queue | Simple queue, 2 concurrent downloads, cancel, retry |
| Progress | Percent, speed, ETA |
| Settings | Download folder, default quality, filename template |
| History | Local list of past downloads (open file / open folder / re-download) |
| Engine | Bundled yt-dlp + ffmpeg, "Update engine" button + auto-check on launch |
| OS | Windows 10/11, macOS (Apple Silicon + Intel), Ubuntu/Debian-based Linux |
| Errors | Friendly messages for the common failures (see section 7) |

### Explicitly out of scope (later)
- Playlists, channels, batch import
- Login/cookies (`--cookies-from-browser`), private or age-gated content
- Accounts, licensing, payments, any backend
- Signed update manifest (MVP pulls yt-dlp releases directly with checksum verification)
- Browser extension, deep link from website (add in v0.2)
- Subtitles, thumbnails, format conversion options
- Mobile
- Store distribution (Mac App Store, Microsoft Store)

---

## 3. Tech stack (MVP)

| Layer | Choice |
|---|---|
| UI | Flutter 3.x (stable), desktop targets: windows, macos, linux |
| State | Riverpod |
| Storage | Drift (SQLite) for history and settings |
| Process | `dart:io` `Process.start` |
| Engine | yt-dlp (standalone binary per OS) + ffmpeg (LGPL static build) |
| JS runtime | **Verify against the current yt-dlp docs.** Recent YouTube support may require an external JS runtime. If so, bundle it as a third sidecar |
| File/folder | `file_picker`, `path_provider`, `open_filex` / `url_launcher` |
| Logging | `logger` plus a rotating local log file |
| CI | GitHub Actions matrix (windows, macos, ubuntu) |
| Website | Single static page (Astro or plain HTML) on Cloudflare Pages or Netlify |

---

## 4. Architecture

```
┌────────────────────── Flutter app ──────────────────────┐
│ UI (screens)                                            │
│   Home (paste + preview) · Queue · History · Settings   │
│                         │                               │
│ State (Riverpod providers)                              │
│                         │                               │
│ Services                                                │
│   MetadataService   → yt-dlp --dump-single-json         │
│   DownloadManager   → queue, concurrency, cancel        │
│   EngineManager     → locate / verify / update binaries │
│   ErrorClassifier   → stderr → friendly error enum      │
│                         │                               │
│ Infra                                                   │
│   ProcessRunner · Drift DB · Logger · PathResolver      │
└───────────────┬─────────────────────────────────────────┘
                ▼
     yt-dlp + ffmpeg (app-data dir)  →  platform CDN  →  file on disk
```

### Project structure
```
ctrl_video/
├─ lib/
│  ├─ main.dart
│  ├─ app/                 # theme, routing
│  ├─ features/
│  │  ├─ home/             # paste, preview, format picker
│  │  ├─ queue/            # active downloads
│  │  ├─ history/
│  │  └─ settings/
│  ├─ services/
│  │  ├─ engine_manager.dart
│  │  ├─ metadata_service.dart
│  │  ├─ download_manager.dart
│  │  ├─ process_runner.dart
│  │  └─ error_classifier.dart
│  ├─ data/                # Drift tables, repositories
│  └─ models/              # MediaInfo, FormatOption, DownloadTask, EngineInfo
├─ assets/engine/          # bundled engine binaries (yt-dlp, ffmpeg)
├─ test/
├─ scripts/                # fetch-engine, package, sign
└─ .github/workflows/
```

---

## 5. Key design decisions

### 5.1 Where the engine lives
Store binaries in the **per-user app-data directory** (e.g. `%APPDATA%/ctrl_video/engine/`, `~/Library/Application Support/ctrl_video/engine/`, `~/.local/share/ctrl_video/engine/`), not inside the install directory. This avoids admin rights for updates and lets the app swap the engine freely.

On first launch, copy the bundled engine there, or download it if you keep the installer small.

### 5.2 Engine updates (MVP version)
1. On launch (at most once per 24h) and on "Update engine": fetch the latest yt-dlp release metadata from GitHub's releases API.
2. Download the platform asset and the release's SHA-256 checksum file.
3. Verify the checksum, then replace the binary atomically (write to a temp file, `chmod +x`, rename). Keep the previous version as `yt-dlp.prev`.
4. If a download fails with an "extractor/outdated" signature, update once automatically and retry once.
5. Roll back to `.prev` if the new binary fails a smoke test (`yt-dlp --version`).

Later versions move to your own signed manifest (ed25519) so you control what clients install.

### 5.3 Process safety
- Always pass arguments as a **list**; never build a shell string.
- Put `--` before the URL so input can never be read as a flag.
- Allowlist hosts (`youtube.com`, `youtu.be`, `instagram.com`, `facebook.com`, `fb.watch`) before running anything.
- Sanitize filenames and output paths.

### 5.4 Core commands

**Metadata**
```
yt-dlp --dump-single-json --no-playlist --no-warnings -- <URL>
```
Parse `title`, `thumbnail`, `duration`, `uploader`, and `formats[]` (`format_id`, `ext`, `height`, `vcodec`, `acodec`, `filesize` or `filesize_approx`).

**Download video**
```
yt-dlp --no-playlist --newline --continue \
  --ffmpeg-location <engine_dir> \
  -f "bv*[height<=1080]+ba/b[height<=1080]" \
  --merge-output-format mp4 \
  -o "<folder>/%(title).150B [%(id)s].%(ext)s" \
  --progress-template "download:%(progress._percent_str)s|%(progress._speed_str)s|%(progress._eta_str)s" \
  -- <URL>
```

**Audio only**
```
yt-dlp -x --audio-format mp3 --audio-quality 0 ... -- <URL>
```

Parse the progress lines on stdout in the app; read stderr for error classification.

### 5.5 Cancel and cleanup
Kill the process **tree** (yt-dlp spawns ffmpeg). Delete leftover `.part` and `.ytdl` files on cancel, but keep them on pause or retry so `--continue` works.

---

## 6. Data model (Drift)

```
DownloadHistory
  id, url, platform, title, thumbnailUrl, filePath,
  format, sizeBytes, status (done|failed|cancelled),
  errorCode?, createdAt, completedAt?

Settings (key/value)
  downloadDir, defaultQuality, filenameTemplate,
  maxConcurrent, lastEngineCheck, engineChannel
```

---

## 7. Error handling

Map yt-dlp output to a small enum with a friendly message and a suggested action:

| Code | Typical cause | User message / action |
|---|---|---|
| `unsupportedUrl` | Host not on the allowlist | "This link isn't supported yet." |
| `private` | Login required / private | "This video needs sign-in. Not supported in this version." |
| `unavailable` | Removed/blocked | "This video isn't available." |
| `geoBlocked` | Region restricted | "Not available in your region." |
| `rateLimited` | HTTP 429 / bot check | "Platform is limiting requests. Try again later." |
| `engineOutdated` | Extractor/sig failure | Auto-update the engine, then retry once |
| `network` | Timeout/DNS | "Check your connection." (Retry button) |
| `disk` | No space / permission | "Can't write to the selected folder." |
| `unknown` | Anything else | Show a short message and a "Copy log" button |

Always keep the raw stderr in the local log, and include a "Copy diagnostic info" button for support.

---

## 8. Screens

1. **Home**: URL field (auto-fills from clipboard), "Fetch" button, preview card (thumbnail, title, duration), quality dropdown, "Download" button.
2. **Queue**: active and pending items with progress bar, speed, ETA, cancel/retry.
3. **History**: searchable list with open file, open folder, delete record, re-download.
4. **Settings**: download folder, default quality, concurrency, engine version with "Check for updates", about and legal text.

---

## 9. Packaging and CI (MVP level)

| OS | Output | Notes |
|---|---|---|
| Windows | Inno Setup `.exe` (per-user install) | Unsigned is fine for private beta; expect SmartScreen warnings |
| macOS | `.dmg` (universal) | Sign + notarize before sharing beyond testers. Sign **every** bundled binary |
| Linux | AppImage | `.deb` can come later |

GitHub Actions: one workflow per OS that runs `flutter test`, builds the release, fetches the matching engine binaries, packages, and uploads artifacts. Cut releases from tags.

---

## 10. Testing plan

- **Unit:** URL validation, format parsing, error classifier (feed it saved stderr samples), filename sanitization.
- **Integration:** run against a fixed set of 30 public test links; record pass/fail per platform per release.
- **Manual matrix:** Windows 11, macOS (Apple Silicon), Ubuntu LTS. Each runs install, download, cancel, retry, engine update, and uninstall.
- **Failure drills:** unplug the network mid-download, fill the disk, kill the app mid-download and resume, corrupt the engine binary (rollback should trigger).
- Use only links you have the right to download (your own uploads or openly licensed videos).

---

## 11. Timeline (solo, part-time friendly)

| Week | Deliverable |
|---|---|
| 1 | Flutter shell, ProcessRunner, metadata fetch and parse, format picker, single download with progress (one OS) |
| 2 | Queue and concurrency, cancel/retry, history DB, settings, error classifier |
| 3 | EngineManager (verify, update, rollback), ffmpeg bundling, cross-OS path handling |
| 4 | Packaging for all three OSes, CI, landing page with download links, private beta |

Buffer: add 1 week for macOS signing/notarization if it is your first time.

---

## 12. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Platforms break extraction often | Engine auto-update + retry; nightly channel option later |
| Bot checks/rate limits (YouTube especially) | Local residential IP helps; clear error messages; cookies feature planned for later |
| macOS signing and notarization friction | Start the Apple Developer setup in week 1 |
| Antivirus false positives on bundled binaries | Download engine from official sources, verify checksums, sign installers |
| Install size grows if a JS runtime is needed | Verify yt-dlp's current requirements in week 1; fetch heavy binaries on first run |
| ffmpeg licensing | Use an LGPL build; keep a notices screen in the app |
| Legal and platform terms exposure | See below |

---

## 13. Legal and compliance (do before public release)

- Downloading from these platforms generally conflicts with their terms of service, and copyright applies to the content itself. Position the tool for content users own or are permitted to save.
- Ship a Terms of Use, Privacy Policy (state clearly that links and files stay on the device), and a copyright contact.
- Don't use platform logos or names in a way that implies affiliation.
- No DRM circumvention.
- Get advice from a lawyer in your jurisdiction and target markets before launch.

---

## 14. Definition of done (v0.1)

- [ ] Installers for Windows, macOS, Linux produced by CI
- [ ] 30-link test set meets the 90% pass rate on each OS
- [ ] Engine update and rollback verified, including the corrupted-binary case
- [ ] All error codes reachable and tested
- [ ] Landing page live with download links and legal pages
- [ ] Private beta with at least 10 testers across the three OSes, with feedback collected

---

## 15. Next versions (after MVP)

- **v0.2:** `ctrlvideo://` deep link from the website, playlist support, subtitles and thumbnails, signed update manifest on your own CDN.
- **v0.3:** optional browser-cookie login, opt-in crash reporting, `.deb` and Flatpak.
- **v1.0:** licensing or monetization (if chosen), polished onboarding, localization.

---

## 16. Open decisions

1. Product name and domain: **ctrl+video** (ctrlvideo.org).
2. Engine delivery: Bundled initial binaries in installer/assets, seeded into app-data on first run.
3. First development & prototype target: Linux (Fedora).
4. Whether yt-dlp's current YouTube support needs a bundled JS runtime (verify in week 1).
5. Monetization model, which determines whether a backend is needed after the MVP.
