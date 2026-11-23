# ctrl+video: UI & Design Guidelines

## 1. Overview
This document specifies the design system, styling principles, and UI conventions for **ctrl+video**.
The design strictly follows **Google's Material Design 3 (MD3)** specifications, tailored for desktop user experiences (Windows, macOS, Linux) with a clean, focused, **neutral palette** inspired by the black & white keycap brand identity.

---

## 2. Brand Identity & Assets
- **Logo Concept**: Minimalist tactile keycap with clean typography ("ctrl" in regular weight, dividing underline, and bold uppercase "VIDEO"), enclosed in a rounded key shape with an offset shadow.
- **Asset Paths**:
  - `lib/assets/logo.png`
  - `assets/branding/logo.png`
- **Application App Bar / Header**:
  - Show the keycap logo (28–32px height) paired with clean title text: `ctrl+video`.
  - Maintain ample breathing room and consistent alignment.

---

## 3. Color System (Neutral MD3 Palette)
Following MD3 with neutral tonal palettes rather than loud vibrant colors, complementing the monochrome keycap branding while maintaining accessible contrast.

### Light Theme
- **Primary / Accent**: `Color(0xFF1E1E1E)` (Deep graphite / near-black)
- **On Primary**: `Color(0xFFFFFFFF)`
- **Primary Container**: `Color(0xFFE8E8EC)` (Subtle cool grey container)
- **On Primary Container**: `Color(0xFF1C1B1F)`
- **Surface**: `Color(0xFFF9F9FB)` (Soft neutral light)
- **Surface Container Lowest**: `Color(0xFFFFFFFF)`
- **Surface Container**: `Color(0xFFF2F2F5)`
- **Surface Container High**: `Color(0xFFEAEAEE)`
- **On Surface**: `Color(0xFF191C1E)`
- **On Surface Variant**: `Color(0xFF45474C)` (Muted secondary text)
- **Outline**: `Color(0xFF75777D)`
- **Outline Variant**: `Color(0xFFC5C6CD)` (Dividers and subtle borders)

### Dark Theme
- **Primary / Accent**: `Color(0xFFE2E2E6)` (Crisp white / silver)
- **On Primary**: `Color(0xFF1A1C1E)`
- **Primary Container**: `Color(0xFF2D2F33)`
- **On Primary Container**: `Color(0xFFE2E2E6)`
- **Surface**: `Color(0xFF131316)` (Deep neutral dark)
- **Surface Container Lowest**: `Color(0xFF0E0E11)`
- **Surface Container**: `Color(0xFF1E1F24)`
- **Surface Container High**: `Color(0xFF282A2F)`
- **On Surface**: `Color(0xFFE2E2E6)`
- **On Surface Variant**: `Color(0xFFC5C6CD)`
- **Outline**: `Color(0xFF8F9097)`
- **Outline Variant**: `Color(0xFF44474E)`

### Status Indicators
- **Success / Completed**: `Color(0xFF2E7D32)` (Light) / `Color(0xFF81C784)` (Dark)
- **Error / Failed**: `Color(0xFFBA1A1A)` (Light) / `Color(0xFFFFB4AB)` (Dark)
- **Warning / Notice**: `Color(0xFFE65100)` (Light) / `Color(0xFFFFB74D)` (Dark)
- **In-Progress / Info**: `Color(0xFF0277BD)` (Light) / `Color(0xFF81D4FA)` (Dark)

---

## 4. Typography
Desktop-optimized MD3 type scale using system fonts (`Roboto`, `Inter`, or platform sans-serif):
- **Display / Header**: Bold, tight letter spacing, clean hierarchy.
- **Body / Captions**: High-contrast, legible at 13px–14px for dense desktop list views and download metrics (speed, ETA).
- **Monospace**: For file paths, version strings, and diagnostic logs (`Roboto Mono`, `Consolas`, or platform monospace).

---

## 5. Desktop Layout & Navigation
- **Navigation Structure**:
  - MD3 `NavigationRail` (expandable or compact with icon + label) pinned to the left edge:
    - 📥 **Home** (Download & Preview)
    - ⏳ **Queue** (Active & Scheduled downloads with badge count)
    - 🕒 **History** (Completed downloads log)
    - ⚙️ **Settings** (App and engine configurations)
- **Window Minimum Dimensions**:
  - Min width: 780px, Min height: 560px.
  - Default recommended window: 960px × 640px.
- **Surface Hierarchy**:
  - Clean elevated card containers (`Card.outlined` with `outlineVariant` border) for download tasks and media previews.
  - Consistent padding: `8px`, `16px`, `24px` grid system.

---

## 6. Component Guidelines
- **Input Fields**:
  - Outlined text field with rounded corners (`12px` radius).
  - Clear paste button embedded as suffix action with clipboard auto-detection.
- **Buttons**:
  - `FilledButton` with subtle rounded corners (`10px`–`12px`) for primary actions ("Download", "Check for Updates").
  - `OutlinedButton` or `TextButton` for secondary controls ("Cancel", "Copy Logs").
- **Progress Bars**:
  - MD3 `LinearProgressIndicator` with rounded ends.
  - Accompanying typography displaying percentage (`78%`), current speed (`4.2 MB/s`), and ETA (`00:45`).
- **Snackbars & Notifications**:
  - MD3 floating floating snackbars for feedback ("Link copied", "Engine updated successfully").
