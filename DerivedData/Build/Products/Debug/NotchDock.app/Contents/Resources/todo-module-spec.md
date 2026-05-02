# ToDo List Module Specification

## Overview
The ToDo module provides a lightweight, premium task manager directly from the macOS menu bar island. It follows NotchDock's core design language — compact, content-driven sizing, smooth micro-animations, and `ThemeTokens` for visual consistency.

> **Canonical spec**: See `/docs/todo-module-spec.md` for the full, authoritative specification.

## Core Features
1. **Interactive Task List**: Tasks can be checked/unchecked with animated feedback.
2. **In-place Task Creation**: Add tasks via the inline input row at the bottom of the list.
3. **Persistence**: Tasks survive app restarts via `UserDefaults` JSON encoding.
4. **Task Management**: Tap to edit inline; hover to reveal delete button; drag to reorder.

## UI Components & Design

### 1. Compact View
- **Icon**: `checklist` (SF Symbol), 13pt semibold.
- **Badge**: Animated capsule (`ThemeTokens.accentColor`) showing remaining task count.

### 2. Expanded View

#### Task Item Row (`ToDoRow`)
- **Checkbox (Left)**: Circle outline → filled circle + `checkmark` on completion. Scale pulse on tap.
- **Task Text (Center)**: 14pt regular, multi-line. Faded + strikethrough when complete.
- **Hover Actions (Right)**: `xmark.circle.fill` delete button + `line.3.horizontal` reorder handle.
- **Row Padding**: 3pt vertical, 6pt leading (ultra-flush left), 8pt trailing.

#### Add Task Row (`AddToDoRow`)
- `plus.circle` icon + plain `TextField`. Arrow submit button appears when text is non-empty.
- **Row Padding**: 5pt vertical, 6pt leading (ultra-flush left).

#### Reorder Behavior
- Live reorder via `ToDoDropDelegate.dropEntered`.
- Dragged row is hidden (`opacity: 0`) to prevent ghost-duplicate artifact.

#### Layout
- `VStack(spacing: 1)` inside `ScrollView`.
- **Width**: Content-driven, `minWidth: 280` — no fixed width.
- **Height**: `min(400, 30 + itemCount × 32 + 60)`, animated on count change.

## Data Persistence
- `UserDefaults`, key: `"com.notchdock.todo.items"`, JSON-encoded `[ToDoItem]`.

## Technical Requirements
- **Protocol**: `NotchDockExtension`
- **ViewModel**: `ToDoViewModel.shared` (singleton, `ObservableObject`)
- **Styling**: `ThemeTokens` throughout
- **Animations**: `ThemeTokens.Spring.standard` for list mutations; `SparkleEffect` on task completion; `AnimatedStrikethrough` for text-centric feedback.
