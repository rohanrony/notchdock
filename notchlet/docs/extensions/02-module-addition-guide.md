# Notchlet Module Addition Guide

## How to add a new module
1. Create a new folder under Extensions/.
2. Add the module's Swift files.
3. Implement the shared NotchletExtension protocol.
4. Add any module-specific service, model, and views.
5. Register the module in ExtensionRegistry.
6. Add settings controls if the module needs configuration.
7. Add a purchase ID only if the module is premium.
8. Validate the module against the spec.

## Module rules
- One module should do one thing well.
- Keep module dependencies out of other modules.
- Put shared UI in NotchletCore/SharedUI.
- Put shared logic in NotchletCore.
- Keep free modules usable without payments.
- Keep paid modules easy to unlock and easy to remove.

## Example module folder
```text
Extensions/FocusStatsExtension/
├── FocusStatsExtension.swift
├── FocusStatsView.swift
├── FocusStatsModel.swift
└── FocusStatsSettingsView.swift
```
