# Quick Access Module Specification

The Quick Access module provides a lightweight snippet manager and persistent note storage directly within the NotchDock island. It allows users to store frequently used text, prompts, and snippets for instant retrieval and copying.

## 1. Core Features

1. **Persistent Snippets**: Items are saved securely in the macOS Keychain, ensuring they survive app restarts and system reboots.
2. **Editable Headings**: Each item features a distinct "Label" (heading) and "Content" field.
3. **One-Tap Copy**: Quick-action icons appear on hover to copy content directly to the system clipboard.
4. **Dynamic Management**: In-place creation and deletion of items with smooth spring animations.
5. **Local-Only Architecture**: All data is stored locally in the secure Keychain; no cloud synchronization or external transmission occurs.

## 2. Visual Design

### 2.1 Compact State (Island)
- **Icon**: `doc.on.clipboard` (SF Symbol).
- **Badge**: A small numerical indicator showing the total number of stored snippets.

### 2.2 Expanded State (Panel)
- **Width**: `320pt` minimum.
- **Max Height**: `400pt` (scrollable).
- **Row Layout**: 
    - **Label (Left)**: 1/3 width, styled with `ThemeTokens.accentColor` and a subtle background fill.
    - **Content (Right)**: Remaining width, styled with `ThemeTokens.secondaryText`.
    - **Hover Actions**: `doc.on.doc` (Copy) and `xmark.circle.fill` (Delete) appear on the far right when the mouse enters the row.
- **Add Action**: A dedicated "Add Item" row at the bottom with a `plus.circle.fill` icon.

## 3. Data Persistence

- **Storage**: macOS Keychain (Service: `com.notchdock.quickaccess`, Account: `items`).
- **Migration**: Automatically migrates legacy data from `UserDefaults` (`com.notchdock.quickaccess.items`) to the secure Keychain on first launch.
- **Format**: JSON-encoded array of `QuickAccessItem` objects.

## 4. Technical Implementation

- **ViewModel**: `QuickAccessViewModel.shared` (Singleton).
- **Protocol**: `NotchDockExtension`.
- **Haptic Feedback**: Standard selection and success haptics for interactions.
- **Animations**: `ThemeTokens.Spring.standard` for list mutations.

## 5. Privacy & Security

- **Keychain Storage**: Unlike standard preferences, items are stored in the system Keychain, providing an additional layer of security for potentially sensitive snippets.
- **No IPC Requirement**: Unlike the previous Clipboard module, Quick Access does not require Apple Event permissions as it does not attempt to control other applications or monitor system copy events beyond its own UI interactions.
