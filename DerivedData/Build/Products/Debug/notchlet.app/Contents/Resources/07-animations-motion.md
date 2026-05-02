# Notchlet Animations and Motion

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
