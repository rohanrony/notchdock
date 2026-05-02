# ToDo Module Specification

The ToDo module is a high-performance, premium task management extension for Notchlet, optimized for rapid entry and intuitive organization directly from the macOS notch.

## 1. Core Architecture

### 1.1 Data Model (`ToDoItem`)
- **ID**: `UUID`
- **Text**: `String`
- **IsCompleted**: `Bool`
- **CreatedAt**: `Date`

### 1.2 State Management (`ToDoViewModel`)
- **Singleton Pattern**: Managed via `ToDoViewModel.shared` to ensure consistency across island and settings views.
- **Persistence**: Automated saving to `UserDefaults` using the `"notchlet_todo_items"` key.
- **Syncing**: Real-time updates across all view instances using `@Published`.

## 2. Visual Design & Aesthetics

### 2.1 Color Palette
- **Active Task**: `ThemeTokens.secondaryText` (Muted gray for reduced glare).
- **Completed Task**: `ThemeTokens.secondaryText.opacity(0.35)` (Deeply dimmed to indicate resolution).
- **Accent**: `ThemeTokens.accentColor` (Used for checkboxes and task entry buttons).
- **Background**: Transparent/Glass material within the Notchlet tray.

### 2.2 Typography
- **Font**: System Sans-Serif, `.regular` weight.
- **Size**: 14pt (Standard for module rows).
- **Wrapping**: `lineLimit(nil)` enabled to support multi-line tasks without expanding tray width.

### 2.3 Grid System
- **Leading Margin**: 6pt ultra-flush alignment for checkboxes.
- **Icon Synchronization**: The tray spans 636pt with 16pt horizontal padding to align perfectly with the island switcher icons.

## 3. Interaction Model

### 3.1 Task Entry
- **Rapid Submission**: Uses `.onSubmit` for instant task creation.
- **Auto-Clear**: The input field is wiped clean immediately upon pressing Enter.
- **Continuous Focus**: The field remains focused after entry for high-speed list building.

### 3.2 Completion Style
- **Native Strikethrough**: Uses system-native `.strikethrough()` for precision across wrapped lines.
- **Animated Reveal**: Visual feedback during check/uncheck actions.
- **Sparkle Effect**: Subtle micro-animation upon task completion for a "premium" feel.

### 3.3 Reordering
- **Custom Delegate**: Implements `ToDoDropDelegate` for reliable drag-and-drop within a `ScrollView`.
- **Grab Handle**: A dedicated `line.3.horizontal` icon provides a clear interaction target for reordering.

## 4. UI Components

### 4.1 Compact View (Island)
- **Leading Aligned**: Checklist icon and remaining count are anchored to the start of the island.
- **Dynamic Badge**: A spring-animated badge shows the number of outstanding tasks.

### 4.2 Expanded View (Tray)
- **Scrollable Layout**: Optimized for vertical stability within the floating notch panel.
- **Dimensions**: Fixed content width of 525pt (75% of island capacity), max height capped at 500pt with adaptive growth.
- **Integrated Input**: The "Add a task" field sits flush at the bottom of the list.

## 5. Persistence & Performance
- **Optimized Loading**: Data is decoded/encoded only when necessary to minimize menu bar overhead.
- **Memory Footprint**: Designed to remain lightweight for permanent background operation.
