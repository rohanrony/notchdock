# Timer Module Specification

The Timer module provides a high-precision countdown utility integrated directly into the notch.

## 1. Visual Design

### 1.1 Compact State (Island)
- **Left of Notch**: A static `timer` SF Symbol.
- **Right of Notch**: The current remaining time in `mm:ss` format (only shown when the timer is running).
- **Font**: Monospaced digit system font (size 13) to prevent layout jitter during countdown.

### 1.2 Expanded State (Panel)
A horizontal layout (HStack) with two primary sections:
- **Time Display/Input**: 
    - When running: Large monospaced time readout (size 36).
    - When stopped: Two editable `TextField` inputs for Minutes and Seconds. Supports auto-tabbing from minutes to seconds when 2 digits are entered.
- **Controls**:
    - **Play/Pause Button**: Large circle fill icon (`play.circle.fill` / `pause.circle.fill`).
    - **Color**: Uses `ThemeTokens.accentColor` (Olive) for the primary action.
    - **Reset Button**: `arrow.clockwise.circle.fill` in secondary gray.

## 2. Settings Configuration
The Timer module features a dedicated tab in the Settings window:
- **Default Duration**: A slider to set the baseline timer (1-60 minutes). This value is used when the timer is reset.
- **Persistence**: Saved via `@AppStorage` as `timer_default_minutes`.
- **Remote Controls**: Start, Pause, and Reset buttons available directly within the Settings UI.

## 3. Interaction & Logic

### 3.1 Timer Behavior
- Uses a `Foundation.Timer` running on the `.common` run loop mode to ensure accuracy even during UI interactions (like scrolling or dragging).
- Countdown format: `mm:ss`.

### 3.2 Alarm System
- Triggers a **double chime** notification sound when the timer reaches zero.
- Sound: `NSSound(named: "Glass")`.
- Sequence: Play -> 0.4s delay -> Play again.

## 4. Technical Implementation
- **ViewModel**: `TimerViewModel` (Singleton).
- **View Components**:
    - `TimerCompactView`
    - `TimerExpandedView`
    - `TimerSettingsView`
- **Product ID**: Free module (no purchase required).
