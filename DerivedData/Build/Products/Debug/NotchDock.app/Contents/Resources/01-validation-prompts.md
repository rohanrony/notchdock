# NotchDock Validation Prompts

## Validate one spec
```text
Review this NotchDock spec document for clarity, contradictions, and missing details.

Goals:
1. Make it precise and production-ready.
2. Remove ambiguity.
3. Keep it modular and buildable in Antigravity.
4. Preserve Markdown structure.
5. Return only the improved document.

Document:
<PASTE ONE MD FILE HERE>
```

## Validate the full spec set
```text
Review the full NotchDock spec set for internal consistency.

Files:
- 01-product-overview.md
- 02-design-system.md
- 03-core-modules.md
- 04-extensions-arch.md
- 05-settings-payments.md
- 06-technical-decisions.md
- 07-animations-motion.md
- 08-monetization-roadmap.md

Tasks:
1. Check for contradictions.
2. Check that the design system matches the product goals.
3. Check that the architecture supports the monetization plan.
4. Check that the free and paid features are consistent.
5. Return a concise list of fixes, then an updated global recommendations section.

Do not rewrite all files. Focus on actionable corrections.
```
