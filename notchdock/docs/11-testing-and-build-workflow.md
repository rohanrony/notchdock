# 11: Testing and Build Workflow

This document outlines the standard procedures for verifying code changes and building the NotchDock application. Following these steps ensures that branding remains consistent, security rules are enforced, and no regressions are introduced into the intelligent selection logic.

## 1. Testing Suite Overview

NotchDock uses a dual-testing approach to ensure both logic and interface stability.

### 1.1 Unit Tests (`NotchDockTests`)
- **Location**: `notchdockTests/notchdockTests.swift`
- **Purpose**: Verifies business logic, data models, and sanitization helpers.
- **Key Areas Covered**:
    - `AppState`: Intelligent notch selection and priority logic.
    - `AppConfig`: Configuration JSON loading and default values.
    - `Security`: AppleScript string sanitization.
    - `Modules`: ViewModel logic for ToDo, QuickAccess, and Music.

### 1.2 UI Tests (`NotchDockUITests`)
- **Location**: `notchdockUITests/notchdockUITests.swift`
- **Purpose**: Verifies the application launches and the core Notch view is present in the window hierarchy.

---

## 2. Standard Development Workflow

### 2.1 Verification (Pre-Commit)
Before submitting a change or starting a new feature, always run:
- **Command + U**: Executes the full test suite.
- **Note on Failures**: The `testIntelligentSelectionLogic` is environment-aware. If it fails, ensure that no external apps (like Music or Spotify) are interfering in a way the test didn't expect.

### 2.2 Building
- **Command + B**: Standard incremental build.
- **Command + Shift + K**: Clean build folder (recommended after changing `AppConfig.json` or project-level settings).

### 2.3 Handling Permissions during Build
- **TCC Prompts**: If you change the Bundle ID, macOS will prompt for Calendar/Reminders access again.
- **Keychain Prompts**: If the binary signature changes, macOS will ask for Keychain access for QuickAccess. **Always click "Always Allow"** to prevent repeated prompts during a single development session.

---

## 3. Pre-Flight Checklist

Whenever a new module is added or a core architecture change is made, verify the following:

1.  **Registry Check**: Ensure the new module is registered in `AppState.init()`.
2.  **Branding Check**: Verify the `NotchDock` module name is used in all `@testable import` statements.
3.  **Documentation Sync**: Update [00-repo-structure.md](file:///Users/rohanroy/Coding/notchdock/notchdock/docs/00-repo-structure.md) if files were added or removed.
4.  **Security Audit**: Run the checks defined in [10-security-checks.md](file:///Users/rohanroy/Coding/notchdock/notchdock/docs/10-security-checks.md), focusing on AppleScript sanitization and minimal entitlements.

## 4. Troubleshooting Build Errors

### "No such module 'NotchDock'"
Ensure that the Test Target's **Host Application** is set to the main `NotchDock` app and that the `@testable import` uses the correct capitalized branding.

### "Couldn't create workspace arena folder"
This is typically a permissions conflict in `DerivedData`. Close Xcode and run:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/NotchDock-*
```
