# Notchlet Modular Build Prompts

## Phase 0
```text
Build the Notchlet project skeleton in Swift and SwiftUI.

Requirements:
- Create the app structure.
- Add NotchletCore and Extensions directories or modules.
- Define the extension protocol.
- Define shared app state and registry objects.
- Add theme tokens and basic scaffolding.
- Do not implement full features yet.

Return code and file structure only.
```

## Phase 1
```text
Build the Notchlet host shell and island UI.

Requirements:
- Create the notch-adjacent floating UI.
- Add compact and expanded states.
- Apply Liquid Glass styling.
- Add curved geometry.
- Add clean spring animations.
- Add a settings button placeholder.

Do not build feature modules in this step.
```

## Phase 2
```text
Implement the free core modules for Notchlet.

Modules:
- Calendar
- Clipboard
- Timer
- Music
- Claude

Requirements:
- Keep each module isolated.
- Give each module compact and expanded views.
- Keep the music module free.
- Do not add AI clipboard actions.
- Keep Claude lightweight and API-key based.
```

## Phase 3
```text
Implement the settings popup and extension management.

Requirements:
- Show installed extensions.
- Show available extensions.
- Support install, enable, disable, and purchase actions.
- Add API key entry for Claude.
- Add feature request and support links.
- Add tip jar options.
- Keep the popup polished and modular.
```

## Phase 4
```text
Implement premium extension plumbing.

Requirements:
- Add $1 extension unlock support.
- Add a purchase manager abstraction.
- Add a sample premium extension for chat history or clipboard pinning.
- Keep free modules unaffected.
- Keep the unlock logic isolated from feature logic.
```

## Phase 5
```text
Polish Notchlet animations and visual design.

Requirements:
- Improve motion for expansion, hover, module switching, and settings.
- Make the interface feel closer to NotchNook.
- Tune the Liquid Glass styling.
- Improve accessibility and reduced motion behavior.
- Keep changes focused on UI and animation only.
```
