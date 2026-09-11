# NotchDock Marketing Routines & Content Calendar

A lightweight, repeatable daily and weekly checklist for managing NotchDock's organic marketing engine.

---

## 1. Daily Marketing Routine (10–15 Minutes)

### Step 1: Discover Active Threads (3 mins)
Run the Reddit thread finder to scan for new, high-intent conversations:
```bash
python3 .agents/skills/notchdock-marketing/scripts/reddit_thread_finder.py --subreddits macapps,MacOS,mac,macsetups --time day
```

Look for:
- Recommendation requests: *"What are the best menu bar / notch apps?"*
- Setup / workspace posts: *"Desktop glow-up / clean setup recommendations"*
- Meeting / productivity pain points: *"How do you quickly join meetings on Mac?"*

### Step 2: Select 1–2 High-Quality Opportunities (2 mins)
- Only choose threads where NotchDock is a **direct, legitimate answer** to the author's question.
- Avoid threads where the OP is launching their own competing app (never hijack launch posts).

### Step 3: Draft & Audit Value-First Comments (5 mins)
- Lead with an answer or insight first.
- Explicitly disclose: `(Disclaimer: I am the developer)`.
- Run the compliance checker:
```bash
python3 .agents/skills/notchdock-marketing/scripts/compliance_checker.py --subreddit macapps --text "Your draft comment..."
```

### Step 4: Execute & Respect Cooldowns (2 mins)
- Wait ≥8–10 minutes between comments if posting in multiple places.
- Log the comment in `.agents/skills/reddit-marketing/resources/campaign_log.md`.

---

## 2. Weekly Growth Cadence

| Day | Primary Focus | Task / Action |
|:---|:---|:---|
| **Monday** | Discovery & Planning | Run weekly thread finder across `r/macapps`, `r/productivity`, and `r/PKMS`. Identify top 3 discussion targets. |
| **Tuesday** | Feature Highlight (X & Reddit) | Share a micro-demo or tip (e.g. Pomodoro timer slider or Apple Notes sync) on X and in relevant Reddit discussions. |
| **Wednesday** | Community & Karma Building | Engage organically on `r/macapps` and `r/MacOS` by helping other users (without links) to build healthy local account karma. |
| **Thursday** | Trend Jacking / Niche Feature | Target live sports or stocks discussions (e.g. upcoming weekend matches or market movements). |
| **Friday** | Weekly Metrics & Directory Pitch | Audit posted comments via `https://safereddit.com/user/<username>`. Submit to 1 new Mac directory (MacMenuBar, BetaList, Awesome-Mac). |
| **Weekend** | Desk Setup Showcase | Engage with `r/macsetups` weekend desk showcases; highlight minimalist desktop aesthetics. |

---

## 3. Monthly Milestone Checklist

- [ ] Check `r/macapps` for the **Monthly App Megathread ("App Pile")** and post a comprehensive update.
- [ ] Pull latest features and changelog using `python3 .agents/skills/notchdock-marketing/scripts/extract_product_context.py`.
- [ ] Review Google Analytics / Plausible / website download metrics to identify highest-converting referral sources.
- [ ] Refresh messaging frameworks based on common customer questions or objections.
