# Music Module Specification

## Overview
The Music module provides a premium, integrated media controller for macOS. It supports Apple Music and Spotify, featuring real-time metadata synchronization, dynamic UI color adaptation, and a visually responsive music visualizer.

## Core Features
1. **Multi-Player Support**: Automatically detects and controls Apple Music and Spotify.
2. **Dynamic Theming**: Extracts the dominant color from album artwork to update the UI accent color (slider, visualizer, shadows).
3. **Playback Controls**: Full control over playback (Play/Pause, Next, Previous) and precise seeking via a custom slider.
4. **App Integration**: Quick-launch button to open the active music player directly from the tray.
5. **Music Visualizer**: Real-time animated visualizer that responds to playback state.

## UI Components & Design

### 1. Compact View (`MusicCompactView`)
- **Artwork (Left)**: 18x18 thumbnail with 4pt corner radius. Fallback is a dynamic gradient with a `music.note` icon.
- **Visualizer (Right)**: 4-bar animated visualizer. Bar heights randomize between 4pt and 14pt when music is playing; reset to static 4pt when paused.
- **Alignment**: Symmetrically straddles the notch using `alignmentGuide(.notchCenter)`.

### 2. Expanded View (`MusicExpandedView`)
- **Artwork Header**: 52x52 high-resolution artwork with 12pt corner radius and a vibrant shadow matching the album's dominant color.
- **Metadata**: 
    - **Title**: 15pt medium text (`ThemeTokens.primaryText`).
    - **Artist**: 13pt medium text (`ThemeTokens.secondaryText`).
- **Quick Action**: 24x24 rounded rectangle button (6pt radius) containing the player's SF Symbol (`apple.logo` or `play.circle.fill`). Opens the app via file-based URL activation to minimize system log noise.
- **Premium Slider**: Custom interactive progress bar. Supports dragging for seeking and updates in real-time.
- **Playback Controls**: 
    - Backward/Forward: 18pt SF Symbols.
    - Play/Pause: 24pt SF Symbol with fixed 28pt width to prevent layout shift.

## Technical Implementation

### 1. Music Manager (`MusicManager`)
- **AppleScript Engine**: Executes control commands via `/usr/bin/osascript` subprocess to avoid system framework overhead and console pollution.
- **State Fetching**: Polls active players for title, artist, position, duration, and artwork URL/data.
- **Permission Handling**: Uses `AEDeterminePermissionToAutomateTarget` to silently check for automation authorization.

### 2. ViewModel (`MusicViewModel`)
- **Polling**: 2-second refresh interval for metadata and playback state.
- **Color Extraction**: Uses `CIContext` and `CIAreaAverage` filter on artwork to determine the UI accent color. Results are cached and animated via `.easeInOut` for smooth transitions.
- **Icon Caching**: Optimized to fetch/generate app icons only when the active player changes, reducing `NSWorkspace` overhead.

### 3. Persistence
- **Compact State**: Remembers the `showCompact` preference via `UserDefaults` (key: `music_show_compact`).

## Design Constraints
- **Width**: `AppConfig.Music.expandedMinWidth` (default: 320pt).
- **Height**: Dynamic based on content and permission status.
- **Aesthetics**: Follows a "Glassmorphism" approach with multi-layered shadows and subtle borders (0.5pt white opacity).
