---
name: reddit-marketing
description: >-
  Reusable skill for Reddit-based community marketing of indie software products.
  Activate when the user asks to find Reddit threads, draft promotional comments,
  execute a Reddit marketing campaign, audit subreddit rules for compliance, or
  research community sentiment. Covers subreddit discovery, rule compliance,
  comment drafting, anti-spam best practices, and campaign tracking.
---

# Reddit Community Marketing Skill

A generic, reusable skill for promoting indie software products on Reddit
while respecting community rules, AutoMod configurations, and account safety.

> **Extensibility**: This skill is product-agnostic. Product-specific skills
> (e.g., `notchdock-marketing`) should reference this skill for Reddit
> mechanics and layer on product-specific positioning, channels, and copy.

---

## Phase 1: Subreddit Research & Discovery

### 1.1 Identify Target Subreddits

For any product, map subreddits across three tiers:

| Tier | Description | Example Categories |
|------|-------------|-------------------|
| **Primary** | Subreddits where the product's exact category is the main topic | `/r/macapps`, `/r/androidapps`, `/r/SaaS` |
| **Secondary** | Adjacent communities where the product solves a pain point | `/r/productivity`, `/r/MacOS`, `/r/macsetups` |
| **Tertiary** | Niche interest communities aligned with specific features | `/r/fantasypremierleague`, `/r/stocks`, `/r/shortcuts` |

### 1.2 How to Research Subreddits

1. **Web Search**: `site:reddit.com/r/<subreddit> "<product category>" OR "<pain point>"` 
2. **Reddit JSON API**: Fetch `https://www.reddit.com/r/<sub>/about/rules.json` for official rules
3. **Reddit Search**: Fetch `https://www.reddit.com/r/<sub>/search.json?q=<keyword>&sort=new&t=week`
4. **Sidebar / Wiki**: Check `https://www.reddit.com/r/<sub>/wiki/index` for extended guidelines

### 1.3 Subreddit Profile Template

For each target subreddit, record:
```yaml
subreddit: r/macapps
members: 120000
relevance_tier: primary
posting_rules:
  self_promo_allowed: true  # with PCP format
  developer_disclosure_required: true
  frequency_limit: "1 post per 30 days"
  karma_requirement: "10 local karma"
  link_types: "official distribution channels only"
automod_notes: "Filters external URLs from low-karma accounts"
best_thread_types:
  - Monthly megathreads (App Pile)
  - "Looking for" recommendation threads
  - Comparison / alternative threads
worst_thread_types:
  - Other developers' launch posts (thread hijacking)
  - Locked/archived threads
```

---

## Phase 2: Subreddit Rule Compliance

### 2.1 Rule Audit Checklist

Before posting in **any** subreddit, the agent MUST verify:

- [ ] **Self-Promotion Policy**: What percentage of activity can be self-promotional?
- [ ] **Developer Disclosure**: Is explicit disclosure required? (e.g., "I am the developer")
- [ ] **Posting Frequency**: How often can the same product be mentioned?
- [ ] **Karma Requirements**: Is there a minimum local karma threshold?
- [ ] **Link Restrictions**: Are external links allowed? Only official domains?
- [ ] **Flair Requirements**: Does the post need specific flair?
- [ ] **Format Requirements**: Does the sub require a specific post template (e.g., PCP)?
- [ ] **Thread Types**: Are there designated promotional threads (megathreads)?

### 2.2 Fetching Rules Programmatically

```bash
# Fetch subreddit rules as JSON
curl -s -A "Mozilla/5.0" "https://www.reddit.com/r/<subreddit>/about/rules.json" | python3 -m json.tool
```

Or via the `read_url_content` tool:
```
URL: https://www.reddit.com/r/<subreddit>/about/rules.json
```

### 2.3 Common AutoMod Patterns That Remove Comments

| Pattern | Trigger | Mitigation |
|---------|---------|------------|
| Low local karma + external URL | Account has <10 karma in subreddit | Build karma first with value-add comments |
| Same URL posted rapidly | Same domain in multiple subs within hours | Space posts 8–12 hours apart |
| Thread hijacking | Promoting in another dev's launch post | Only comment in recommendation/discussion threads |
| Live thread URL filter | External links in match/event threads | Use text-only mentions, no hyperlinks |

---

## Phase 3: Comment & Post Drafting

### 3.1 Comment Types (Ranked by Safety & Effectiveness)

| Type | Risk | Effectiveness | When to Use |
|------|------|---------------|-------------|
| **Recommendation Reply** | Low | Very High | User explicitly asks for app recommendations |
| **Megathread Entry** | Low | Medium | Monthly app showcase / "what are you using" threads |
| **Comparison Comment** | Medium | High | Threads comparing alternatives in your category |
| **Standalone PCP Post** | Medium | Very High | Official self-promotion post (once per 30 days) |
| **Launch Post in Other Dev's Thread** | HIGH (banned) | Negative | **NEVER do this** |

### 3.2 The PCP (Problem-Comparison-Pricing) Template

Many subreddits (especially `r/macapps`) require this format:

```markdown
[App] <App Name> – <One-line value proposition>

### 🧩 [Problem]
<What pain point does this solve?>

### ⚖️ [Comparison]
<How does it compare to alternatives? Be specific and honest.>

### 🏷️ [Pricing]
<Pricing model, free tier, compatibility>
```

### 3.3 Comment Drafting Rules

1. **Lead with Value**: Answer the user's question first, THEN mention your product
2. **Be Specific**: Reference exact features that solve the stated problem
3. **Developer Disclosure**: Always include `(Disclaimer: I am the developer)` or `(Full disclosure: I built this)`
4. **No Marketing Speak**: Write like a fellow community member, not a press release
5. **Official Links Only**: Link to your official domain, never URL shorteners
6. **Adapt to Context**: Read the thread tone — match informal/formal register

---

## Phase 4: Anti-Spam & Account Safety

### 4.1 Rate Limiting

- **Between Comments**: Wait ≥8 minutes between posts across ALL subreddits
- **Between Posts**: Wait ≥24 hours between standalone posts
- **Domain Velocity**: Never post the same URL in >2 subreddits within 12 hours
- **Reddit Rate Limit Error**: If you see "Rate limit exceeded", wait the full stated duration

### 4.2 Building Organic Karma

Before promoting, the account should:
1. Make 5–10 genuine, helpful comments in target subreddits (no links)
2. Upvote and engage with community content
3. Build ≥10 local karma in subreddits that require it

### 4.3 Shadow-Ban Detection

Signs that comments are being shadow-removed:
- Comment visible when logged in, invisible in incognito
- Zero upvotes/replies after 24 hours on an active thread
- Check via `https://safereddit.com/user/<username>` or Reddit JSON API

---

## Phase 5: Campaign Tracking

### 5.1 Post-Campaign Audit

After posting, verify each comment:

```bash
# Check if comment is publicly visible via safereddit
# URL: https://safereddit.com/user/<username>
```

### 5.2 Tracking Template

```markdown
| # | Date | Subreddit | Thread | Type | Status | Views/Upvotes |
|---|------|-----------|--------|------|--------|---------------|
| 1 | YYYY-MM-DD | r/macapps | App Pile Aug | Megathread | ✅ Visible | 3 upvotes |
```

---

## References

- [Reddit Content Policy](https://www.redditinc.com/policies/content-policy)
- [Reddiquette](https://www.reddithelp.com/en/categories/reddit-101/reddit-basics/reddiquette)
- Subreddit-specific rules: Fetch via `https://www.reddit.com/r/<sub>/about/rules.json`
- Shadow-ban checker: `https://safereddit.com/user/<username>`
