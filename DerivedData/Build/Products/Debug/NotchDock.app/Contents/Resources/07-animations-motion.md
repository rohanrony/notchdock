# NotchDock Animations and Motion

## Goals
Make the island feel premium, curved, and alive.

## Required interactions
- Hover glow.
- Expand and collapse spring motion.
- Module switching motion.
- Settings panel entry and exit.
- Timer progress changes.
- Music activity animation.
- Clipboard copy feedback: Subtle haptic and "Copied" toast fade.
- Premium unlock success: A one-time "Shine" animation over the unlocked card + success haptic.
- Permission denial: A gentle horizontal "Shake" if access is required but not granted.

## Haptic Feedback (macOS)
- **Selection**: Trigger `generic` haptic on module switching.
- **Success**: Trigger `confirmation` haptic on purchase or clipboard restore.
- **Warning**: Trigger `alignment` haptic if a timer is force-stopped.

## Motion style
- Use soft, controlled spring curves.
- Keep movement short and responsive.
- Respect reduced motion.
- Avoid cartoony bounce.

## Design feel
The result should feel closer to NotchNook than to a generic menu bar tool.

## Layout & Appearance Guidelines
- **Color Palette**: The primary background color is `#1B1B1B`. The secondary text is `#8c8c8c`.
- **Typography**: The primary font is the native macOS San Francisco system font.
- **Dynamic Width Form Factor**: To prevent elements from being hidden under the physical hardware notch, the software island dynamically expands horizontally based on module content. It uses a `320pt` central spacer between the left/right icons to guarantee it clears even the widest MacBook notches.
- **Top Row Alignment**: When expanded, module switcher icons sit perfectly within the menu bar height (left of the hardware notch) and the settings sit to the right. Icons are sized exactly to menu bar standards (13pt font, 24x24 bounds).
- **Icon Styling**: Module icons are styled as flat, outline-free squircle buttons. The active icon receives a soft `white.opacity(0.15)` fill.
- **Notch Blending**: The shape seamlessly blends into the top screen bezel. The top edge is transparent so it merges with the physical black hardware bezel, while multi-layered drop shadows create a 3D float effect below.
- **Tray Layout**: The expanded tray area sits tightly below the top row, with all redundant internal padding stripped from modules to achieve maximum vertical compactness.
