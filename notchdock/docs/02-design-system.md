# NotchDock Design System

## Visual direction
Use solid, 3D-inspired surfaces with deep layered drop shadows. The island, expanded panels, and settings popover should feel like floating hardware UI, avoiding busy outlines.

## Style rules
- Use solid colors (Background: #1B1B1B) instead of liquid glass for the main tray.
- Use multi-layered drop shadows to create a floating 3D effect.
- Avoid outlines and strokes on the main tray and module icons to maintain a clean look.
- Use SF Symbols and the native macOS San Francisco system font.
- Keep accent color restrained and system-like.
- Text colors: Primary text is #dbdbdb, Secondary text is a highly visible #8c8c8c.

## Motion rules
- Use spring-based expansion and collapse.
- Use matched geometry for active module transitions.
- Keep animations subtle and polished.
- Respect Reduce Motion.

## Core surfaces
- Island compact view.
- Island expanded view.
- Settings popover.
- Extension cards.
- Premium unlock sheets.

## Notch Symmetry & Icon Distribution
- **Symmetric Layout**: The tray maintains visual symmetry around the physical notch by ensuring an equal number of icon slots on both sides.
- **Symmetry Algorithm**:
  - The number of slots per side is `max(2, ceil(N/2) + 1)` where N is the number of active module icons.
  - Right side always reserves 2 slots for the fixed action icons (Pin and Settings).
  - Module icons are distributed such that the first three occupy the left side, the fourth occupies the right (next to the pin), and subsequent icons alternate.
- **Notch Spacing**: A tight `4pt` breathing room is maintained between the physical notch edges and the nearest icons on both sides.
- **Dynamic Width**: The tray width is calculated as `max(LeftBarWidth + NotchGap + RightBarWidth, ActiveModuleMinWidth)`, ensuring it never shrinks smaller than its icon bar but expands gracefully for complex modules like the Calendar.

## Interaction & State
- **Pinning**: A dedicated "Pin" action allows users to lock the notch in its expanded state, overriding the default hover-to-collapse behavior.
  - **Inactive State**: Thin `pin` icon (SF Symbol), secondary text color, upright.
  - **Active State**: Solid `pin.fill` icon, upright, tinted with a warm amber accent (`hue: 0.08`), and a 15% opacity amber background glow.
- **Active Module**: Indicated by a soft white background fill (Color.white.opacity(0.15)) behind the top bar icon.
- **Hover Hit-Test**: When in the idle (collapsed) state, the interactive area is clipped to the `detectedNotchWidth`. This ensures the island only expands when the user intends to interact with the notch area itself.
- **Interactive State**: Use a subtle "Hover Glow" (white at 10% opacity) on glass surfaces.

## Menu Bar Icon (Minimized Mode)
- **Design**: A custom vector-based `NSImage` representing the application's identity.
- **Shape**: A filled "notch" silhouette centered inside an un-filled rounded square border.
- **Behavior**: Uses `isTemplate = true` to automatically adapt to system accessibility and theme colors (White on Dark menu bar, Black on Light menu bar).
- **Interaction**: Standard macOS `NSStatusItem` behavior with a native dropdown menu.
