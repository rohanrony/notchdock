# NotchDock Build Planning Prompt

```text
You are planning a modular build for NotchDock in Google Antigravity using Gemini.

Context:
- NotchDock is a macOS notch utility.
- It uses Swift and SwiftUI.
- It uses Apple-style Liquid Glass, curved motion, and a modular extension architecture.
- The spec is split into multiple markdown files.

Your task:
1. Read the spec set.
2. Produce a phase-based build plan.
3. Split the work into small, safe phases that can be implemented incrementally.
4. For each phase, list:
   - Goal
   - Files likely to change
   - Dependencies
   - Risks
   - Done criteria
5. Ensure the plan is suitable for vibe coding with Antigravity and Gemini.

Return only Markdown.
```
