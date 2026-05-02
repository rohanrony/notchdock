# ToDo List Module Specification

## Overview
The ToDo List module for Notchlet provides a lightweight, accessible way for users to manage tasks directly from the menu bar "island". It follows the core design language of Notchlet, utilizing the olive accent color and premium animations.

## Core Features
1. **Interactive Task List**: A list of tasks that can be checked/unchecked.
2. **In-place Task Creation**: Quickly add new tasks without leaving the island.
3. **Persistence**: Completed tasks remain visible until explicitly deleted.
4. **Task Management**: Edit existing tasks and delete them via a hover-action.

## UI Components & Design

### 1. Compact View
- **Icon**: `checklist` (SF Symbol).
- **Behavior**: Displays the current task count or a simplified indicator.

### 2. Expanded View
The expanded view displays the full list of ToDos.

#### Task Item Row
- **Checkbox (Left)**: 
    - Unchecked: A circular outline.
    - Checked: An olive-filled circle (`ThemeTokens.accentColor`) with a white tick (`checkmark`) inside.
- **Task Note (Center)**: 
    - Displays the text of the ToDo.
    - Click to enter edit mode.
- **Delete Action (Right)**:
    - Visible only on hover.
    - Icon: `trash` (SF Symbol).
    - Color: System red or subtle gray.

#### New Task Creation
- **Trigger**: 
    - Pressing "Enter" while focus is on the list.
    - Clicking a `+` button which appears in place of the checkbox below the last existing task.
- **Input**: Inline text field that appears within the list structure.

## Detailed Behavior

### Checking/Unchecking
- Clicking the circle toggles the task's completion state.
- Completion state is visually represented by the olive circle and white tick.
- Checked tasks are NOT automatically removed or hidden; they persist until deleted.

### Adding a ToDo
- A dedicated "Add New" row exists at the bottom of the list.
- It features a `+` icon where the checkbox usually is.
- Clicking the `+` or pressing Enter in an empty row focuses the text input.

### Deleting a ToDo
- On hover of a task row, a delete icon appears on the far right.
- Clicking delete removes the task from the model immediately with a slide-out animation.

### Editing a ToDo
- Clicking on the text of an existing task switches it to an editable `TextField`.
- Pressing "Enter" or clicking outside saves the changes.

## Data Persistence
- Tasks are stored locally (likely via `UserDefaults` or a dedicated JSON file in the app support directory) to ensure they survive app restarts.

## Technical Requirements
- **Protocol**: Implements `NotchletExtension`.
- **View**: SwiftUI-based implementation.
- **Styling**: Uses `ThemeTokens` for consistency.
- **Animations**: Uses `ThemeTokens.Spring.standard` for list updates.
