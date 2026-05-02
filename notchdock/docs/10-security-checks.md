# Dynamic Island‑style macOS App Specification

## 1. Purpose
- A lightweight macOS app that provides Dynamic Island‑style status indicators and notifications.
- No full‑screen UI; mostly menu bar / status‑area interaction.
- Built locally using Antigravity and AI models (Gemini / Claude).

## 2. Tech stack
- Language: Swift (SwiftUI / AppKit).
- Dependencies: minimal, via Swift Package Manager or equivalent.
- Platform: macOS (targeting App Store distribution if possible).

## 3. Security & Privacy

### 3.1 Data handling
- No sensitive user data (credentials, tokens, personal identifiers) stored in plain text.
- Any secrets must be stored in the macOS Keychain, not in `UserDefaults`, `Info.plist`, or source code.
- If logs are written, they must not contain user messages or PII.

### 3.2 Network & APIs
- All network traffic must use HTTPS (or secure native channels).
- Gemini / Claude API keys must be loaded at runtime (e.g., via environment‑like config) and never committed to source control.
- The app must not send unnecessary data to any backend; only what is strictly required.

### 3.3 Permissions & entitlements
- The app must run in a sandbox when targeting the App Store.
- Entitlements must be minimal:
  - No `com.apple.security.files.all` unless strictly required.
  - Prefer `com.apple.security.files.user-selected` or similar restricted scopes.
- No unnecessary entitlements (camera, microphone, screen recording, accessibility, automation) unless explicitly justified.

### 3.4 Code security
- No hardcoded API keys, passwords, or secrets in any Swift, Objective‑C, or script files.
- **Automation Sanitization**: Any string interpolated into AppleScript or shell commands (e.g., in `MusicModule`) must be sanitized to prevent script injection.
- **Untrusted IPC Handling**: Data retrieved from external processes or third-party apps must be validated before use in business logic or UI rendering.
- Dependencies must be kept up to date and checked for known vulnerabilities.

### 3.5 Build & distribution
- The app must be:
  - Signed with a valid Apple Developer certificate.
  - Notarized for Gatekeeper‑trusted distribution.
  - Built with Hardened Runtime enabled.
- **Process Isolation**: If the app uses a Launch Helper or multiple extensions, secure shared storage via App Groups must be used.
- The app must pass Apple’s App Store review (no misleading metadata or duplicated UIs).

### 3.6 User‑facing privacy
- If the app collects any user data, a short privacy notice must be visible in‑app or via an external link.
- **Privacy-Aware Logging**: Use native `os.log` with private formatting for any potentially sensitive strings to ensure they don't appear in system-wide console logs.
- The app must not leak prompts, user messages, or system state to third parties without explicit consent.