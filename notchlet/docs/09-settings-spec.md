# Notchlet Settings Specification

This document defines the structure, design, and functionality of the Notchlet settings window.

## 1. Overview
The Settings window is the primary interface for users to configure the application, manage active modules, and handle permissions. It follows a professional macOS sidebar-based navigation pattern using `NavigationSplitView`.

## 2. Visual Design
- **Window Type**: Standard macOS Utility Window.
- **Dimensions**: 720px x 520px.
- **Navigation**: Sidebar on the left, Detail view on the right.
- **Theme**: Supports System Dark/Light modes. Sidebar uses `ThemeTokens.sidebarBackground` with a premium selection style.
- **Typography**: Uses system rounded fonts for headers and standard system fonts for body text to feel native to macOS.

## 3. Sidebar Structure

### 3.1 General Settings
The entry point for global app configuration.
- **Modules**: List of all available modules with toggles to enable/disable them.
- **Module Order**: Interactive list allowing users to drag-and-drop to reorder modules in the notch switcher.
- **System**:
    - **Launch at Login**: Managed via `SMAppService.mainApp`.

### 3.2 Extensions
A "Coming Soon" page showcasing the future roadmap for Notchlet.
- **Roadmap**: Displays planned modules (Slack, Messages, WhatsApp, Mail, Airdrop, Live Camera).
- **Status**: Visual indicators for "Planned" or "Experimental" features.

### 3.3 Modules (Dynamic Section)
A dynamic list of all **enabled** modules. Selecting a module opens its specific configuration page (provided by the module's `settingsView`).

#### Common Module Settings Patterns:
- **Permission Cards**: Status cards for Calendar, Music, etc., with "Allow Access" or "Fix in Settings" buttons.
- **Display Toggles**: Controls like "Show in Compact Mode".
- **Feature Specifics**: Sliders for thresholds (Calendar) or feature toggles (ToDo).

### 3.3 Help Section
- **Support**: Links to Request a Feature, Report a Bug, and Contact Support. Includes a link to the User Guide.
- **About**: Displays version info, credits ("Handcrafted by Rohan Roy"), and links to Privacy Policy and Website.

## 4. Technical Implementation

### 4.1 State Management (`AppState`)
- `extensionOrder: [String]`: Array of module IDs in user-defined order.
- `enabledExtensionIDs: Set<String>`: IDs of active modules.
- `activeExtensionID: String?`: The currently selected module in the notch.

### 4.2 Module Protocol (`NotchletExtension`)
```swift
protocol NotchletExtension: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var iconName: String { get }
    var isPremium: Bool { get }
    
    @ViewBuilder var settingsView: AnyView { get }
}
```

### 4.3 Navigation Layout
```swift
NavigationSplitView {
    VStack {
        SidebarItem(title: "General", section: .general)
        Section("Modules") {
            ForEach(enabledModules) { ext in
                SidebarItem(title: ext.displayName, section: .module(ext.id))
            }
        }
        Section("Help") {
            SidebarItem(title: "Support", section: .support)
            SidebarItem(title: "About", section: .about)
        }
    }
} detail: {
    // Current section view
}
```

## 5. Interaction Design
- **Opening Settings**: Triggered via the gear icon in the expanded Notch view.
- **Dynamic Updates**: Changes to module visibility or order reflect instantly in the `IslandView`.
- **Permission Flow**: Permissions are handled within each module's settings page to provide context-aware authorization.

