# NotchDock Repo Structure

```text
notchdock/
├── NotchDock.xcodeproj
├── notchdock/
│   ├── Assets.xcassets/
│   ├── build-and-run.sh
│   ├── notchdock.entitlements
│   ├── NotchDockApp/
│   │   ├── NotchDockApp.swift
│   │   ├── IslandView.swift
│   │   ├── SettingsView.swift
│   │   └── AppState.swift
│   ├── NotchDockCore/
│   │   ├── NotchDockExtension.swift
│   │   ├── ExtensionRegistry.swift
│   │   ├── AppConfig.swift
│   │   ├── ThemeTokens.swift
│   │   └── SharedUI/
│   ├── Extensions/
│   │   └── Modules/
│   │       ├── CalendarModule.swift
│   │       ├── MusicModule.swift
│   │       ├── ToDoModule.swift
│   │       ├── TimerModule.swift
│   │       └── QuickAccessModule.swift
│   └── docs/
│       ├── 00-repo-structure.md
│       ├── 01-product-overview.md
│       ├── ...
│       └── extensions/
│           ├── ...
│           ├── quick-access-module.md
│           └── todo-module-spec.md
├── notchdockTests/
├── notchdockUITests/
├── packaging/
└── README.md
```
