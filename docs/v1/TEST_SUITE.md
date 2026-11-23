# ctrl+video: Integration & Acceptance Test Suite

This document defines the 30-link acceptance test suite across the 3 supported platforms for v0.1 MVP verification.

---

## Acceptance Criteria
- **Pass threshold**: At least 90% (27/30 links) must successfully fetch preview metadata and download readable media.
- **Output validation**: Downloaded file must be valid MP4 or MP3 and playable via standard media player (VLC, mpv, or system default).

---

## 1. YouTube Test Links (10 targets)
| ID | Type | Sample Characteristics | Target Result |
|---|---|---|---|
| YT-01 | Standard Video (Public) | Standard 1080p landscape | Pass |
| YT-02 | YouTube Shorts | Vertical 9:16 video | Pass |
| YT-03 | Music / Audio Track | High quality stereo audio | Pass (Audio Only MP3) |
| YT-04 | 4K / High Bitrate Video | High resolution format list | Pass (Downscaled to 1080p/720p) |
| YT-05 | 60fps Gameplay Video | High frame rate | Pass |
| YT-06 | Short Clip (< 1 min) | Quick download | Pass |
| YT-07 | Long Video (> 30 min) | Chunked download with resume | Pass |
| YT-08 | Educational / Speech Video | Clean speech audio | Pass |
| YT-09 | Creative Commons Video | Openly licensed media | Pass |
| YT-10 | Video with Special Characters in Title | Filename sanitization | Pass |

---

## 2. Instagram Test Links (10 targets)
| ID | Type | Sample Characteristics | Target Result |
|---|---|---|---|
| IG-01 | Public Reel (Music track) | Standard reel | Pass |
| IG-02 | Public Video Post | Square / portrait post | Pass |
| IG-03 | High-Engagement Creator Reel | CDN routed video | Pass |
| IG-04 | Nature / Landscape Reel | 1080x1920 video | Pass |
| IG-05 | Voiceover Reel | Spoken audio muxing | Pass |
| IG-06 | Short Meme Reel (< 15s) | Fast extraction | Pass |
| IG-07 | Tutorial Reel | Clean visual frames | Pass |
| IG-08 | Sports / Action Reel | Fast-moving frames | Pass |
| IG-09 | Carousel Video Slide | First video extracted | Pass |
| IG-10 | Brand Showcase Video | Public post | Pass |

---

## 3. Facebook Test Links (10 targets)
| ID | Type | Sample Characteristics | Target Result |
|---|---|---|---|
| FB-01 | Public Page Video | Standard 1080p/720p video | Pass |
| FB-02 | Facebook Reel (Public) | Vertical format | Pass |
| FB-03 | News Broadcast Clip | High clarity audio | Pass |
| FB-04 | Tech / Product Demo | Public creator page | Pass |
| FB-05 | Short Comedy Clip | Fast download | Pass |
| FB-06 | Cooking / Recipe Video | Muxed audio/video | Pass |
| FB-07 | fb.watch Shortened URL | Redirect resolution | Pass |
| FB-08 | High Definition Live VOD | Post-stream recording | Pass |
| FB-09 | Community Showcase Video | Public group video | Pass |
| FB-10 | Music Performance Clip | Stereo sound stream | Pass |

---

## Failure Drills Checklist
- [x] Network interruption during download triggers friendly error with retry option.
- [x] Non-supported URL input triggers invalid URL indicator.
- [x] Engine corruption test triggers rollback to `.prev` binary.
