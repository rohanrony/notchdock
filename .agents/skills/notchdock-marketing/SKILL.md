---
name: notchdock-marketing
description: >-
  Dedicated marketing and growth engine for NotchDock. Activate when the user asks to
  market NotchDock, find relevant Reddit threads or communities, draft marketing copy
  or comments, plan daily marketing routines, execute a launch, or expand growth across
  Reddit, X/Twitter, Product Hunt, Mac app directories, and video platforms.
---

# NotchDock Marketing & Growth Skill

A complete, adaptable marketing skill for **NotchDock** (the macOS Dynamic Island & Productivity Hub).
Combines dynamic codebase context extraction, Reddit community engagement, compliance auditing,
and multi-channel distribution.

> **Inheritance**: This skill builds on top of the generic [`reddit-marketing`](../reddit-marketing/SKILL.md)
> skill for platform mechanics, layering on NotchDock-specific positioning, channels, and copy.

---

## 🛠️ Step 1: Extract Up-to-Date Product Context

Never rely on hardcoded features or stale pricing. Before drafting any marketing material, run the context extraction helper to pull the latest updates from `PRD.md`, `CHANGELOG.md`, and the live website:

```bash
python3 .agents/skills/notchdock-marketing/scripts/extract_product_context.py --markdown
```

### Context Sources
- **Feature Specs & Architecture**: [`PRD.md`](file:///Users/rohanroy/Coding/notchdock-source/PRD.md)
- **Recent Releases & Fixes**: [`CHANGELOG.md`](file:///Users/rohanroy/Coding/notchdock-source/CHANGELOG.md)
- **Official Website**: `https://notchdock.app`
- **Official Blog**: `https://notchdock.app/blog`
- **Releases & DMG Downloads**: `https://github.com/rohanrony/notchdock/releases/`

---

## 🎯 Step 2: Channel & Thread Discovery

### Target Subreddit Matrix
Review the full channel breakdown in [`subreddit_matrix.md`](./resources/subreddit_matrix.md):

1. **`r/macapps`** (Primary Hub): Best for launches and recommendations. *Requires PCP format & 10 local karma.*
2. **`r/MacOS` & `r/mac`**: Best for discussions on notch utilization, menu bar clutter, and must-have utilities.
3. **`r/macsetups`**: Best for aesthetic desktop glow-up showcases and clean workspace setups.
4. **`r/productivity` & `r/PKMS`**: Best for Meeting Navigator (1-click Zoom) and Apple Notes scratchpad capture.
5. **`r/PremierLeague` & `r/stocks`**: Best for feature-specific discussions (live scores & ticker pinning).

### Find Active Threads

**Primary Method (Recommended)**: Use the agent's `search_web` tool for reliable discovery:
```
search_web: "site:reddit.com/r/macapps best mac apps OR notch OR productivity" (past week)
search_web: "site:reddit.com/r/MacOS macbook notch app recommendations" (past week)
```

**Alternative**: Use the browser to search Reddit directly, or run the script (may be blocked by Cloudflare):
```bash
python3 .agents/skills/notchdock-marketing/scripts/reddit_thread_finder.py --subreddits macapps,MacOS,macsetups --time week
```

---

## ✍️ Step 3: Crafting & Auditing Marketing Copy

### Messaging Frameworks
Consult [`messaging_frameworks.md`](./resources/messaging_frameworks.md) for tested angles:
- **Angle A: Meeting Navigator**: "Never scramble for a Zoom link again."
- **Angle B: Live Sports & Stock Tickers**: "Watch live Premier League scores in the notch while working."
- **Angle C: Apple Notes Scratchpad**: "Rich-text notes that sync natively with Apple Notes."
- **Angle D: Desktop Glow-Up**: "The cleanest way to utilize your MacBook's hardware notch."

### Run Compliance Audit
Before publishing, ALWAYS run the compliance checker to ensure developer disclosure, link safety, and correct formatting:
```bash
python3 .agents/skills/notchdock-marketing/scripts/compliance_checker.py --subreddit macapps --text "Draft text..."
```

---

## 🚀 Step 4: Multi-Channel Growth Expansion

Refer to [`marketing_playbook_multichannel.md`](./resources/marketing_playbook_multichannel.md) for non-Reddit growth:

1. **Product Hunt**: Launch kit, asset guidelines, and maker comment templates.
2. **X / Twitter**: 10-second micro-video demos and "Build in Public" changelog highlights.
3. **Short-Form Video (TikTok / Reels / Shorts)**: *"3 Mac apps that feel like macOS Sequoia."*
4. **Mac App Directories**: Submissions to MacMenuBar.com, Awesome-Mac, and MacStories.
5. **Hacker News (Show HN)**: Pure Swift 6, AppKit overlay, 100% local-only privacy positioning.

---

## 📅 Step 5: Daily Routine & Campaign Tracking

Follow the operating cadence in [`content_calendar_and_routines.md`](./resources/content_calendar_and_routines.md):

1. **Morning Scan (3 mins)**: Run `reddit_thread_finder.py`.
2. **Select & Draft (5 mins)**: Pick 1–2 genuine recommendation threads; audit with `compliance_checker.py`.
3. **Execute & Cooldown (2 mins)**: Maintain ≥8–10 minute gaps between posts.
4. **Log Activity**: Record posts in [`campaign_log.md`](../reddit-marketing/resources/campaign_log.md).
5. **Review Learnings**: Consult [`past_campaigns_and_learnings.md`](./references/past_campaigns_and_learnings.md).

---

## 📂 Skill Architecture & Files

```text
.agents/skills/
├── reddit-marketing/                       # Generic, reusable Reddit engine
│   ├── SKILL.md                            # Core Reddit marketing rules & mechanics
│   └── resources/
│       ├── campaign_log.md                 # Cross-session activity tracker
│       └── subreddit_profiles.md           # Audited subreddits template
│
└── notchdock-marketing/                    # NotchDock-specific growth skill
    ├── SKILL.md                            # Main NotchDock marketing runbook
    ├── scripts/
    │   ├── extract_product_context.py      # Pulls latest features/pricing from repo & site
    │   ├── reddit_thread_finder.py         # Searches active Reddit threads
    │   └── compliance_checker.py           # Audits copy for rules & disclosure
    ├── resources/
    │   ├── subreddit_matrix.md             # Subreddit tiers, rules, and best angles
    │   ├── messaging_frameworks.md         # Hooks, value props, PCP templates, objection handlers
    │   ├── marketing_playbook_multichannel.md # Product Hunt, X, Video, Directories, Show HN
    │   └── content_calendar_and_routines.md # Daily & weekly marketing checklists
    └── references/
        └── past_campaigns_and_learnings.md # Historical post-mortems and AutoMod insights
```
