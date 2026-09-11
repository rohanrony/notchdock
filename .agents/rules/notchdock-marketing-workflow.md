# NotchDock Marketing Workflow Shortcut

When the user mentions or types any of the following triggers:
- `/notchdock` or `/notchdock-marketing`
- `/notchdock daily marketing`
- `NotchDock marketing` or `run daily marketing`
- Or runs `/goal` with NotchDock marketing

You MUST execute the standard NotchDock daily marketing procedure:

## Procedure
1. **Activate Skills**: Activate `notchdock-marketing` and `reddit-marketing`.
2. **Execute Workflow Runner**: Run `python3 .agents/skills/notchdock-marketing/scripts/run_daily_marketing.py`.
3. **Discover Live High-Intent Threads**: Search active discussions across `r/macapps`, `r/MacOS`, `r/macsetups`, `r/productivity`, `r/PremierLeague`, or `r/stocks` using `search_web` or the finder script.
4. **Draft Tailored, Compliant Comments**:
   - For `r/macapps`: Use the structured PCP template (Problem-Comparison-Pricing) and mandatory developer disclosure `(Disclaimer: I am the developer)`.
   - For `r/MacOS` / `r/macsetups` / `r/productivity`: Craft organic, value-first advice addressing the user's specific problem before mentioning NotchDock.
5. **Audit Quality**: Verify with `compliance_checker.py`.
6. **Present Daily Action Briefing**: Show the discovered threads and the ready-to-post drafts so the user can easily review and approve them.
