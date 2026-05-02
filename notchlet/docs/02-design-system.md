# Notchlet Design System

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

## State indicators
- **Locked Extension**: Use 50% opacity on icons with a subtle "Price Tag" token in the corner (e.g., "$1.00").
- **Unlocked/Premium**: Use a restrained "Accent" glow on the card border to signify premium status.
- **Active Module**: Indicated by a soft white background fill (Color.white.opacity(0.15)) behind the top bar icon, without any borders or outlines.
- **Interactive State**: Use a subtle "Hover Glow" (white at 10% opacity) on glass surfaces.

