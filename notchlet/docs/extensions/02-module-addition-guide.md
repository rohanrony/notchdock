# Notchlet Module Addition Guide

## How to add a new module
1. Create a new Swift file under `Extensions/Modules/` (e.g., `MyNewModule.swift`).
2. Implement the shared `NotchletExtension` protocol.
3. Add any module-specific services, models, and views within the same file or a sub-folder if complex.
4. Register the module in `ExtensionRegistry`.
5. Add settings controls to the module's `settingsView`.
6. Validate the module against the design system (`ThemeTokens`).

## Module rules
- One module should do one thing well.
- Keep module dependencies out of other modules.
- Put shared UI in NotchletCore/SharedUI.
- Put shared logic in NotchletCore.
- Keep free modules usable without payments.
- Keep paid modules easy to unlock and easy to remove.

Extensions/Modules/
└── FocusStatsModule.swift
    ├── struct FocusStatsModule: NotchletExtension
    ├── class FocusStatsViewModel: ObservableObject
    └── struct FocusStatsExpandedView: View
