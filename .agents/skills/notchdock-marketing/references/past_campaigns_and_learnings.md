# Past Campaigns & Marketing Learnings

A running log of real-world marketing experiments, AutoMod triggers, successful posts, and failure post-mortems for NotchDock.

---

## 1. Key Empirical Learnings

### A. AutoMod & Karma Thresholds
- **Observation**: `r/macapps` and large subreddits use aggressive AutoMod rules that automatically filter comments containing external URLs if the user account has <10 local karma or low account age.
- **Remedy**:
  - Build local karma first by commenting helpful, non-promotional feedback.
  - In initial comments, use plain-text mentions (`notchdock.app`) rather than markdown hyperlinks if karma is fresh.
  - Always include explicit developer disclosure (`Disclaimer: I am the developer`) to pass manual mod review.

---

### B. Thread Hijacking vs. Organic Recommendations
- **Failure Mode**: Dropping a comment promoting NotchDock inside another developer's app launch thread (e.g. Grabbit download manager launch).
  - *Result*: Perceived as "thread hijacking" or bad community etiquette; high probability of user downvotes or mod deletion.
- **Success Mode**: Posting inside:
  - Organic "Looking for..." or "What apps do you use?" recommendation threads.
  - Setup & customization showcases ("Giving my desktop a glow up").
  - The official monthly `r/macapps` Megathread ("App Pile").

---

### C. Live Event Threads (Sports & Match Threads)
- **Failure Mode**: Posting promotional links in fast-moving live match threads (e.g. `r/PremierLeague` match threads).
  - *Result*: Live match threads have strict zero-link policies; AutoMod immediately removes any comment containing a URL.
- **Remedy**: Only mention score-tracking utilities in weekly discussion threads, fantasy league threads, or general tech setup posts. Never post links in live match threads during game time.

---

### D. Rate Limiting & Cooldowns
- **Observation**: Reddit enforces both IP-level and account-level velocity limits. Posting >2 promotional comments with links within 10 minutes often triggers a 429 ("Rate limit exceeded - wait 5 minutes") or silent shadow-hiding.
- **Best Practice**:
  - Minimum **8–10 minute delay** between comments.
  - Limit active promotional comments to **2–3 per day**.
  - Check comment visibility via `https://safereddit.com/user/<username>` to verify they are publicly viewable.

---

## 2. Successful Post Archive

### Case 1: `r/macapps` August App Pile Megathread
- **Format**: Structured PCP (Problem-Comparison-Pricing) breakdown.
- **Outcome**: Successfully posted and retained; positive reception due to adherence to community standards.
- **Why it worked**: Followed exact subreddit guidelines and designated megathread location.

### Case 2: Habitat (Workspace/Productivity) Thread
- **Format**: Contextual comparison highlighting NotchDock's local-first architecture and Meeting Navigator.
- **Outcome**: Verified live and visible.
- **Why it worked**: Directly answered the OP's discussion around menu bar and desktop clutter.
