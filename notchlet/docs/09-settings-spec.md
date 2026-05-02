# Notchlet Settings Specification

This document defines the structure, design, and functionality of the Notchlet settings window.

## 1. Overview
The Settings window is the primary interface for users to configure the application, manage extensions, and customize the notch behavior. It follows a standard macOS sidebar-based navigation pattern.

## 2. Visual Design
- **Window Type**: Standard macOS Utility Window.
- **Dimensions**: 700px x 500px (resizable).
- **Navigation**: Sidebar on the left, Detail view on the right (`NavigationSplitView`).
- **Theme**: Supports System Dark/Light modes, with a slight translucency (Glassmorphism) in the sidebar.

## 3. Sidebar Sections

### 3.1 General Settings
- **App Settings**: 
    - **Launch at Login**: Toggle to start Notchlet automatically.
    - **Module Order**: A list where users can drag-and-drop to change the order of modules in the notch switcher.
    - **Home View Customization**: A multi-select list or set of toggles to choose which modules/widgets appear on the "Home View".
- **API Keys**: Configuration for Claude API and other external services (Stored in Keychain).

### 3.2 Modules
A dynamic list of all **enabled** modules. Selecting a module opens its specific settings page.
- **Protocol Requirement**: Each module must implement a `settingsView` property.
- **Default View**: "No specific settings for this module."

### 3.3 Extensions (Store)
- **Marketplace**: List of all available modules (Free and Premium).
- **Management**: Enable/Disable toggles for each module.
- **Payments**: 
    - Unlock premium modules ($1.00 each).
    - Restore Purchases button.
    - Tip Jar ($5, $10, $20).

### 3.4 Support & Feedback
- Feature Request, Bug Report, and Contact Support buttons.

### 3.5 About
- **App Name**: Notchlet
- **Project Lead**: Rohan Roy
- **Contact**: viberDev@gmail.com
- **Version**: Dynamic version string (e.g., v1.0.0 Build 42).
- **Legal**: Links to Privacy Policy and Terms of Service.

## 4. Technical Implementation

### 4.1 State Management (`AppState`)
- `extensionOrder: [String]`: Array of module IDs in user-defined order.
- `homeViewModuleIDs: Set<String>`: IDs of modules selected for the Home View.
- `enabledExtensionIDs: Set<String>`: IDs of active modules.

### 4.2 Module Protocol (`NotchletExtension`)
```swift
protocol NotchletExtension: Identifiable {
    // ... existing properties
    @ViewBuilder var settingsView: AnyView { get }
}
```

### 4.3 Navigation Layout
```swift
NavigationSplitView {
    List(selection: $selectedSection) {
        Section("General") { ... }
        Section("Modules") { ... }
        Section("Store") { ... }
        Section("Support") { ... }
    }
} detail: {
    // Switch based on selection
}
```

## 5. Interaction Design
- **Opening Settings**: Triggered via a gear icon in the expanded Notch view or a menu bar icon.
- **Instant Feedback**: Changes to module order or visibility should reflect immediately in the Notch UI without requiring an app restart.
