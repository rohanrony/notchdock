# NotchDock Repo Structure

```text
notchdock/
├── notchdock.xcodeproj
├── NotchDockApp/
│   ├── NotchDockApp.swift
│   ├── IslandView.swift
│   ├── SettingsView.swift
│   └── AppState.swift
├── NotchDockCore/
│   ├── NotchDockExtension.swift
│   ├── ExtensionRegistry.swift
│   ├── AppConfig.swift (JSON/Swift)
│   ├── ThemeTokens.swift
│   └── SharedUI/
│       ├── SectionCard.swift
│       └── SettingsRow.swift
├── Extensions/
│   └── Modules/
│       ├── CalendarModule.swift
│       ├── MusicModule.swift
│       ├── ToDoModule.swift
│       ├── TimerModule.swift
│       ├── ClaudeModule.swift
│       └── ClipboardModule.swift
├── Docs/
│   ├── 00-repo-structure.md
│   ├── 01-product-overview.md
│   ├── 02-design-system.md
│   ├── 04-extensions-arch.md
│   ├── 05-settings-payments.md
│   ├── 06-technical-decisions.md
│   ├── 07-animations-motion.md
│   ├── 08-monetization-roadmap.md
│   └── 09-settings-spec.md
│   └── extensions/
│       ├── 02-module-addition-guide.md
│       ├── 03-core-modules.md
│       ├── calendar-module.md
│       ├── music-module-spec.md
│       ├── timer-module.md
│       └── todo-module-spec.md
└── Resources/ (Assets.xcassets, etc.)
```
