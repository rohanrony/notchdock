#!/usr/bin/env python3
"""
NotchDock SEO & GEO Pillar Blog Generator
Compiles 77 high-authority, high-intent pillar blog posts across 7 core clusters,
cleans up low-quality/redundant/cannibalizing posts, and updates blog/index.html,
sitemap.xml, and public/llms.txt.
"""

import os
import sys
import json
import re
import subprocess

# Add scripts directory to path to import data modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "data"))

from cluster1_sports import CLUSTER_1_ARTICLES
from cluster2_markets import CLUSTER_2_ARTICLES
from cluster3_focus import CLUSTER_3_ARTICLES
from cluster4_media import CLUSTER_4_ARTICLES
from cluster5_alternatives import CLUSTER_5_ARTICLES
from cluster6_hardware import CLUSTER_6_ARTICLES
from cluster7_developer import CLUSTER_7_ARTICLES

ALL_NEW_ARTICLES = (
    CLUSTER_1_ARTICLES +
    CLUSTER_2_ARTICLES +
    CLUSTER_3_ARTICLES +
    CLUSTER_4_ARTICLES +
    CLUSTER_5_ARTICLES +
    CLUSTER_6_ARTICLES +
    CLUSTER_7_ARTICLES
)

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
BLOG_DIR = os.path.join(BASE_DIR, "blog")
PUBLIC_DIR = os.path.join(BASE_DIR, "public")

ORIGINAL_ARTICLES = [
    {
        "slug": "macbook-notch-pomodoro-timer-deep-work",
        "title": "How to Master Deep Work with a MacBook Notch Pomodoro Timer: Distraction-Free Focus on macOS",
        "url": "https://notchdock.app/blog/macbook-notch-pomodoro-timer-deep-work.html",
        "date": "2026-09-28",
        "meta_desc": "How an ambient Pomodoro focus timer inside the MacBook camera notch eliminates window clutter, prevents alarm fatigue, and protects flow state during deep work.",
        "badge_text": "Deep Work & Focus",
        "badge_icon": "fa-solid fa-brain"
    },
    {
        "slug": "youtube-music-controls-macbook-notch-kaset",
        "title": "How to Control YouTube Music Directly from Your MacBook Notch: Real-Time Playback, Artwork & Likes with NotchDock and Kaset",
        "url": "https://notchdock.app/blog/youtube-music-controls-macbook-notch-kaset.html",
        "date": "2026-09-27",
        "meta_desc": "How to control YouTube Music from your MacBook notch with live seek scrubber, dynamic album art color glow, and 1-click Like button using NotchDock and Kaset.",
        "badge_text": "Native Audio & Kaset",
        "badge_icon": "fa-brands fa-youtube"
    },
    {
        "slug": "manchester-city-vs-manchester-united-live-score-tracker-mac",
        "title": "How to Track Manchester City vs Manchester United Live on Your Mac Notch: Score Summary, Real-Time Stats & Silent Alerts",
        "url": "https://notchdock.app/blog/manchester-city-vs-manchester-united-live-score-tracker-mac.html",
        "date": "2026-09-12",
        "meta_desc": "How to follow the Manchester Derby (Man City vs Man United) live on macOS using NotchDock's ambient camera notch widget without screen distraction.",
        "badge_text": "Sports & Live Scores",
        "badge_icon": "fa-solid fa-futbol"
    },
    {
        "slug": "track-cpi-oil-prices-sp500-market-indexes-live-mac",
        "title": "How to Track CPI Inflation, Crude Oil Prices, and S&P 500 Swings Live on Your Mac Notch",
        "url": "https://notchdock.app/blog/track-cpi-oil-prices-sp500-market-indexes-live-mac.html",
        "date": "2026-09-12",
        "meta_desc": "How energy commodities, CPI inflation reports, and S&P 500 equities move together, and how to track live market reactions in the MacBook notch.",
        "badge_text": "Macro Economics",
        "badge_icon": "fa-solid fa-chart-line"
    },
    {
        "slug": "upcoming-cpi-inflation-data-market-impact-live-mac-tracker",
        "title": "Upcoming CPI Inflation Data: How It Impacts the Stock Market and How to Track the Live Reaction on Your Mac",
        "url": "https://notchdock.app/blog/upcoming-cpi-inflation-data-market-impact-live-mac-tracker.html",
        "date": "2026-09-12",
        "meta_desc": "Macroeconomic playbook for upcoming US CPI releases, the 8:30 AM ET algorithmic market reaction, and live pre-market futures tracking in the Mac notch.",
        "badge_text": "Economic Playbook",
        "badge_icon": "fa-solid fa-scale-balanced"
    },
    {
        "slug": "intelligent-mac-notifications-live-updates",
        "title": "The Death of Intrusive Banners: Why Intelligent Notch Notifications & Live Activities are the Future of macOS",
        "url": "https://notchdock.app/blog/intelligent-mac-notifications-live-updates.html",
        "date": "2026-08-20",
        "meta_desc": "Why traditional top-right notification banners disrupt deep work and how intelligent, ambient notch live updates solve alert fatigue on Mac.",
        "badge_text": "Architecture & UX",
        "badge_icon": "fa-solid fa-bell-slash"
    },
    {
        "slug": "macbook-notch-dynamic-island-live-sports-stocks",
        "title": "How to Turn Your MacBook Notch Into an Always-On Live Activity Center for Sports, Stocks & Tasks",
        "url": "https://notchdock.app/blog/macbook-notch-dynamic-island-live-sports-stocks.html",
        "date": "2026-08-18",
        "meta_desc": "A comprehensive guide to configuring real-time sports tickers, intraday stock watchlists, and task widgets directly inside your MacBook camera bezel.",
        "badge_text": "Use Cases",
        "badge_icon": "fa-solid fa-bolt"
    },
    {
        "slug": "how-to-fix-mac-notification-fatigue",
        "title": "How to Fix macOS Notification Fatigue: The Power of Silent, Glanceable Notch Tickers",
        "url": "https://notchdock.app/blog/how-to-fix-mac-notification-fatigue.html",
        "date": "2026-08-15",
        "meta_desc": "A 3-tier notification triage framework to eliminate alert overload while keeping critical live updates glanceable.",
        "badge_text": "Deep Work & Focus",
        "badge_icon": "fa-solid fa-brain"
    }
]

ALL_AVAILABLE_ARTICLES = ORIGINAL_ARTICLES + ALL_NEW_ARTICLES

def sanitize_html(text):
    if not text:
        return ""
    # Replace '<' not immediately followed by a tag name starter with '&lt;'
    return re.sub(r'<(?![a-zA-Z/!?])', '&lt;', str(text))

def render_table(table_data):
    if not table_data:
        return ""
    headers = table_data.get("headers", [])
    rows = table_data.get("rows", [])
    
    th_html = "".join([f'<th style="padding: 14px; color: var(--text-white); font-size: 0.95rem;">{sanitize_html(h)}</th>' for h in headers])
    
    tr_html = ""
    for idx, r in enumerate(rows):
        bg = 'background: rgba(74, 222, 128, 0.04);' if idx % 2 == 1 else ''
        tds = ""
        for c_idx, cell in enumerate(r):
            sanitized_cell = sanitize_html(cell)
            if c_idx == 0:
                tds += f'<td style="padding: 14px; color: #4ade80; font-weight: 700;">{sanitized_cell}</td>'
            elif c_idx == 1:
                tds += f'<td style="padding: 14px; color: var(--text-white);">{sanitized_cell}</td>'
            else:
                tds += f'<td style="padding: 14px; color: var(--text-muted);">{sanitized_cell}</td>'
        tr_html += f'<tr style="border-bottom: 1px solid var(--border-color); {bg}">{tds}</tr>'
        
    return f"""
    <div style="margin: 24px 0; overflow-x: auto;">
      <table style="width: 100%; border-collapse: collapse; border: 1px solid var(--border-color); border-radius: 12px; overflow: hidden;">
        <thead>
          <tr style="background: rgba(255, 255, 255, 0.05); text-align: left;">
            {th_html}
          </tr>
        </thead>
        <tbody>
          {tr_html}
        </tbody>
      </table>
    </div>
    """

def render_article_html(article):
    slug = article["slug"]
    title = sanitize_html(article["title"])
    meta_desc = sanitize_html(article["meta_desc"])
    keywords = sanitize_html(article["keywords"])
    badge_text = sanitize_html(article["badge_text"])
    badge_icon = article["badge_icon"]
    read_time = article["read_time"]
    date = article["date"]
    lead = sanitize_html(article["lead"])
    aeo_q = sanitize_html(article["aeo_q"])
    aeo_a = sanitize_html(article["aeo_a"])
    sections = article.get("sections", [])
    setup_steps = article.get("setup_steps", [])
    faqs = article.get("faqs", [])
    related_slugs = article.get("related_slugs", [])

    # Canonical URL
    canonical_url = f"https://notchdock.app/blog/{slug}.html"

    # JSON-LD Schema
    schema = {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "TechArticle",
                "@id": f"{canonical_url}#article",
                "headline": title,
                "description": meta_desc,
                "url": canonical_url,
                "datePublished": f"{date}T12:00:00Z",
                "dateModified": f"{date}T12:00:00Z",
                "author": {
                    "@type": "Organization",
                    "name": "NotchDock Engineering & Productivity Lab",
                    "url": "https://notchdock.app/"
                },
                "publisher": {
                    "@type": "Organization",
                    "name": "NotchDock",
                    "url": "https://notchdock.app/",
                    "logo": "https://notchdock.app/assets/logo.jpg"
                },
                "speakable": {
                    "@type": "SpeakableSpecification",
                    "cssSelector": [".speakable-answer", ".aeo-answer-box p"]
                }
            },
            {
                "@type": "BreadcrumbList",
                "@id": f"{canonical_url}#breadcrumb",
                "itemListElement": [
                    {
                        "@type": "ListItem",
                        "position": 1,
                        "name": "Home",
                        "item": "https://notchdock.app/"
                    },
                    {
                        "@type": "ListItem",
                        "position": 2,
                        "name": "Blog",
                        "item": "https://notchdock.app/blog/"
                    },
                    {
                        "@type": "ListItem",
                        "position": 3,
                        "name": title,
                        "item": canonical_url
                    }
                ]
            }
        ]
    }

    # Sections HTML
    sections_html = ""
    for sec in sections:
        sec_h2 = sanitize_html(sec.get("h2", ""))
        sec_content = sanitize_html(sec.get("content", ""))
        sec_table = render_table(sec.get("table"))
        sections_html += f"""
        <h2>{sec_h2}</h2>
        {sec_content}
        {sec_table}
        """

    # Setup steps HTML
    setup_html = ""
    if setup_steps:
        steps_items = "".join([f"<li><strong>Step {i+1}:</strong> {sanitize_html(step)}</li>" for i, step in enumerate(setup_steps)])
        setup_html = f"""
        <h2>Step-by-Step Setup Guide</h2>
        <ol style="color: var(--text-muted); line-height: 1.8; margin-left: 20px;">
          {steps_items}
        </ol>
        """

    # FAQs HTML
    faqs_html = ""
    if faqs:
        faq_items = ""
        for item in faqs:
            q = sanitize_html(item.get("q", ""))
            a = sanitize_html(item.get("a", ""))
            faq_items += f"""
            <h3 style="color: var(--text-white); font-size: 1.1rem; margin-top: 24px;">{q}</h3>
            <p style="color: var(--text-muted); line-height: 1.6;">{a}</p>
            """
        faqs_html = f"""
        <h2>Frequently Asked Questions</h2>
        <div style="margin-top: 20px;">
          {faq_items}
        </div>
        """

    # Related Guides HTML
    related_html = ""
    if related_slugs:
        cards_html = ""
        for r_slug in related_slugs:
            target = next((a for a in ALL_AVAILABLE_ARTICLES if a["slug"] == r_slug), None)
            if target:
                r_title = target["title"]
                r_badge = target["badge_text"]
                r_desc = target["meta_desc"]
                cards_html += f"""
                <a href="/blog/{r_slug}.html" class="related-guide-card">
                  <span class="related-guide-tag"><i class="{target['badge_icon']}"></i> {r_badge}</span>
                  <h4 class="related-guide-title">{r_title}</h4>
                  <p class="related-guide-excerpt">{r_desc}</p>
                  <span class="related-guide-link">Read Guide <i class="fa-solid fa-arrow-right"></i></span>
                </a>
                """
        if cards_html:
            related_html = f"""
            <div class="related-guides-section">
              <h3><i class="fa-solid fa-book-open text-green"></i> Related Engineering & Productivity Guides</h3>
              <div class="related-guides-grid">
                {cards_html}
              </div>
            </div>
            """

    full_html = f"""<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/jpg" href="/assets/logo.jpg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    
    <!-- Primary Meta Tags -->
    <title>{title} | NotchDock</title>
    <meta name="title" content="{title} | NotchDock" />
    <meta name="description" content="{meta_desc}" />
    <meta name="keywords" content="{keywords}" />
    <meta name="author" content="NotchDock Engineering Team" />
    <meta name="robots" content="index, follow" />
    <link rel="canonical" href="{canonical_url}" />
    <link rel="llms-txt" type="text/markdown" href="/llms.txt" />

    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="article" />
    <meta property="og:url" content="{canonical_url}" />
    <meta property="og:title" content="{title} | NotchDock" />
    <meta property="og:description" content="{meta_desc}" />
    <meta property="og:image" content="https://notchdock.app/assets/logo.jpg" />

    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image" />
    <meta property="twitter:url" content="{canonical_url}" />
    <meta property="twitter:title" content="{title} | NotchDock" />
    <meta property="twitter:description" content="{meta_desc}" />
    <meta property="twitter:image" content="https://notchdock.app/assets/logo.jpg" />

    <!-- Structured Data (JSON-LD) -->
    <script type="application/ld+json">
    {json.dumps(schema, indent=2)}
    </script>

    <!-- FontAwesome & Styles -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="/style.css">
  </head>
  <body>

    <!-- Navigation Header -->
    <header class="navbar">
      <div class="navbar-container">
        <a href="/" class="logo-link">
          <img src="/assets/logo.jpg" alt="NotchDock Logo" class="nav-logo" id="nav-logo-img" />
          <span class="nav-brand"><span class="brand-dark">Notch</span><span class="brand-olive">Dock</span></span>
        </a>
        <nav class="nav-menu">
          <a href="/#features" class="nav-item">Features</a>
          <a href="/why-notchdock.html" class="nav-item">Why NotchDock</a>
          <a href="/compare/mac-notch-apps.html" class="nav-item">Compare</a>
          <a href="/blog/" class="nav-item active" style="color: var(--accent-green); font-weight: 600;">Blog</a>
          <a href="/#showcase" class="nav-item">Showcase</a>
          <a href="/#faq" class="nav-item">FAQ</a>
          <a href="https://github.com/rohanrony/notchdock" target="_blank" rel="noopener" class="nav-item" title="View GitHub Repository"><i class="fa-brands fa-github" style="font-size: 1.15rem; vertical-align: middle;"></i></a>
          <a href="https://github.com/rohanrony/notchdock/releases/latest/download/notchdock.dmg" target="_blank" rel="noopener" class="btn btn-secondary nav-btn">Download</a>
        </nav>
      </div>
    </header>

    <!-- Main Content Container -->
    <main>
      
      <!-- Article Header -->
      <header class="article-header">
        <div class="article-breadcrumb">
          <a href="/">Home</a>
          <i class="fa-solid fa-chevron-right" style="font-size: 0.7rem;"></i>
          <a href="/blog/">Blog</a>
          <i class="fa-solid fa-chevron-right" style="font-size: 0.7rem;"></i>
          <span class="current">{title}</span>
        </div>

        <div class="article-meta-row">
          <span class="blog-category-badge"><i class="{badge_icon}"></i> {badge_text}</span>
          <span style="color: var(--text-muted); font-size: 0.88rem;">• Published {date}</span>
          <span style="color: var(--text-muted); font-size: 0.88rem;">• {read_time}</span>
        </div>

        <h1 class="article-title">{title}</h1>
        <p class="article-lead speakable-answer">
          {lead}
        </p>
      </header>

      <!-- Article Body Container -->
      <div class="article-body-container">
        <article class="article-content">

          <!-- AEO Direct Answer Box -->
          <div class="aeo-answer-box">
            <h3><i class="fa-solid fa-bolt" style="color: var(--accent-green);"></i> Direct Answer: {aeo_q}</h3>
            <p>
              {aeo_a}
            </p>
          </div>

          {sections_html}

          {setup_html}

          {faqs_html}

          <!-- Download CTA Box -->
          <div class="article-cta-box">
            <h3>Transform Your MacBook Notch Today</h3>
            <p>Download NotchDock for free and replace noisy notifications with intelligent, ambient live activities inside your screen notch.</p>
            <a href="https://github.com/rohanrony/notchdock/releases/latest/download/notchdock.dmg" target="_blank" rel="noopener" class="btn btn-primary btn-lg"><i class="fa-solid fa-download"></i> Download NotchDock for Mac (Free DMG)</a>
          </div>

          {related_html}

        </article>
      </div>

    </main>

    <!-- Footer -->
    <footer class="footer">
      <div class="footer-container">
        <div class="footer-col brand-col">
          <div class="footer-logo">
            <img src="/assets/logo.jpg" alt="NotchDock Logo" class="nav-logo" />
            <span class="nav-brand"><span class="brand-dark">Notch</span><span class="brand-olive">Dock</span></span>
          </div>
          <p class="footer-desc">The ultimate productivity dock built into the MacBook camera notch. Crafted for macOS.</p>
          <div class="social-links">
            <a href="https://github.com/rohanrony/notchdock" target="_blank" rel="noopener" aria-label="GitHub"><i class="fa-brands fa-github"></i></a>
            <a href="https://x.com/NotchDock" target="_blank" rel="noopener" aria-label="Twitter"><i class="fa-brands fa-x-twitter"></i></a>
          </div>
        </div>
        <div class="footer-col">
          <h4>Product</h4>
          <a href="/#features">Features</a>
          <a href="/why-notchdock.html">Why NotchDock</a>
          <a href="/compare/mac-notch-apps.html">Compare Apps</a>
          <a href="/blog/">Blog</a>
          <a href="/#faq">FAQ</a>
        </div>
        <div class="footer-col">
          <h4>Features</h4>
          <a href="/features/mac-pomodoro-notes.html">Pomodoro & Notes</a>
          <a href="/features/mac-sports-tracker.html">Live Sports Tracker</a>
          <a href="/features/mac-stock-portfolio.html">Stock Portfolio</a>
          <a href="/features/mac-clipboard-manager.html">Clipboard History</a>
        </div>
        <div class="footer-col">
          <h4>Legal</h4>
          <a href="/privacy.html">Privacy Policy</a>
          <p class="copyright" style="margin-top: 1rem; color: var(--text-muted); font-size: 0.85rem;">&copy; 2026 NotchDock. All rights reserved.</p>
        </div>
      </div>
    </footer>

  </body>
</html>
"""
    return full_html

def cleanup_orphan_articles():
    original_slugs = {a["slug"] for a in ORIGINAL_ARTICLES}
    curated_slugs = {a["slug"] for a in ALL_NEW_ARTICLES}
    keep_files = {"index.html"} | {f"{s}.html" for s in original_slugs} | {f"{s}.html" for s in curated_slugs}

    deleted_count = 0
    for filename in os.listdir(BLOG_DIR):
        if filename.endswith(".html") and filename not in keep_files:
            file_path = os.path.join(BLOG_DIR, filename)
            os.remove(file_path)
            deleted_count += 1
            print(f"Deleted low-quality/redundant post: {filename}")
    print(f"Cleaned up {deleted_count} low-quality/redundant articles from blog/.")

def update_blog_index():
    index_path = os.path.join(BLOG_DIR, "index.html")
    
    # Read the clean baseline with the 8 original articles
    cmd = ["git", "show", "f8e3ed4:blog/index.html"]
    base_content = subprocess.check_output(cmd, env={"GIT_CONFIG_GLOBAL": "/dev/null"}).decode("utf-8")

    # Create cards for the curated articles
    cards_html = ""
    json_ld_posts = []

    for art in ALL_NEW_ARTICLES:
        slug = art["slug"]
        cluster = art["cluster"]
        badge_text = art["badge_text"]
        badge_icon = art["badge_icon"]
        read_time = art["read_time"]
        title = art["title"]
        meta_desc = art["meta_desc"]
        date = art["date"]

        cat_tag = f"{cluster} live-activities"

        card = f"""
          <!-- Article: {title} -->
          <a href="/blog/{slug}.html" class="blog-card" data-category="{cat_tag}">
            <div class="blog-card-header">
              <span class="blog-category-badge"><i class="{badge_icon}"></i> {badge_text}</span>
              <span class="blog-read-time"><i class="fa-regular fa-clock"></i> {read_time}</span>
            </div>
            <div class="blog-card-body">
              <h2 class="blog-card-title">{title}</h2>
              <p class="blog-card-excerpt">
                {meta_desc}
              </p>
              <div class="blog-card-footer">
                <div class="blog-card-author">
                  <i class="fa-solid fa-circle-user"></i>
                  <span>Engineering Lab</span>
                </div>
                <span class="blog-read-more">Read Article <i class="fa-solid fa-arrow-right"></i></span>
              </div>
            </div>
          </a>
        """
        cards_html += card

        json_ld_posts.append({
            "@type": "BlogPosting",
            "headline": title,
            "url": f"https://notchdock.app/blog/{slug}.html",
            "datePublished": date,
            "dateModified": date,
            "description": meta_desc
        })

    # Total articles = 8 original + 77 curated = 85
    total_articles = len(ORIGINAL_ARTICLES) + len(ALL_NEW_ARTICLES)
    updated_filter_pills = f"""<!-- Topic Filter Pills -->
        <div class="blog-tags-bar" id="blog-filters">
          <span class="blog-tag-pill active" data-filter="all"><i class="fa-solid fa-layer-group"></i> All Articles ({total_articles})</span>
          <span class="blog-tag-pill" data-filter="sports-stocks"><i class="fa-solid fa-trophy"></i> Sports & Market Tickers</span>
          <span class="blog-tag-pill" data-filter="focus"><i class="fa-solid fa-brain"></i> Deep Work & Focus</span>
          <span class="blog-tag-pill" data-filter="media"><i class="fa-solid fa-music"></i> Media & YouTube Music</span>
          <span class="blog-tag-pill" data-filter="alternatives"><i class="fa-solid fa-scale-balanced"></i> App Comparisons</span>
          <span class="blog-tag-pill" data-filter="hardware"><i class="fa-solid fa-desktop"></i> Hardware & Displays</span>
          <span class="blog-tag-pill" data-filter="developer"><i class="fa-solid fa-shield-halved"></i> Developer & Privacy</span>
        </div>"""

    content = re.sub(r'<!-- Topic Filter Pills -->\s*<div class="blog-tags-bar" id="blog-filters">.*?</div>', updated_filter_pills, base_content, flags=re.DOTALL)

    # Insert cards at end of existing grid (right before </div>\s*<!-- Call to Action Banner -->)
    insertion_marker = '<!-- Call to Action Banner -->'
    parts = content.split(insertion_marker)
    if len(parts) == 2:
        last_div_idx = parts[0].rfind('</div>')
        new_first_part = parts[0][:last_div_idx] + cards_html + "\n        </div>\n\n        "
        content = new_first_part + insertion_marker + parts[1]

    # Update JSON-LD
    try:
        match = re.search(r'"blogPost":\s*\[(.*?)\]\s*\},', content, re.DOTALL)
        if match:
            existing_posts_str = match.group(1).strip()
            new_posts_json = ",\n            " + ",\n            ".join([json.dumps(p, indent=14).strip() for p in json_ld_posts])
            updated_posts_str = existing_posts_str + new_posts_json
            content = content[:match.start(1)] + updated_posts_str + content[match.end(1):]
    except Exception as e:
        print(f"Warning updating JSON-LD in blog/index.html: {e}")

    with open(index_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Updated blog/index.html with {total_articles} total cards ({len(ORIGINAL_ARTICLES)} original + {len(ALL_NEW_ARTICLES)} curated).")

def update_sitemap():
    sitemap_path = os.path.join(PUBLIC_DIR, "sitemap.xml")
    cmd = ["git", "show", "f8e3ed4:public/sitemap.xml"]
    base_sitemap = subprocess.check_output(cmd, env={"GIT_CONFIG_GLOBAL": "/dev/null"}).decode("utf-8")

    # Ensure Pomodoro article is included
    pomodoro_url = "https://notchdock.app/blog/macbook-notch-pomodoro-timer-deep-work.html"
    if pomodoro_url not in base_sitemap:
        pomo_entry = f"""  <url>
    <loc>{pomodoro_url}</loc>
    <lastmod>2026-09-28</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
"""
        base_sitemap = base_sitemap.replace("</urlset>", pomo_entry + "</urlset>")

    new_urls = ""
    for art in ALL_NEW_ARTICLES:
        slug = art["slug"]
        date = art["date"]
        url_entry = f"""  <url>
    <loc>https://notchdock.app/blog/{slug}.html</loc>
    <lastmod>{date}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
"""
        if f"https://notchdock.app/blog/{slug}.html" not in base_sitemap:
            new_urls += url_entry

    full_sitemap = base_sitemap.replace("</urlset>", new_urls + "</urlset>")
    with open(sitemap_path, "w", encoding="utf-8") as f:
        f.write(full_sitemap)
    loc_count = len(re.findall(r'<loc>', full_sitemap))
    print(f"Updated public/sitemap.xml with {loc_count} total URLs (24 base + {len(ALL_NEW_ARTICLES)} curated).")

def update_llms_txt():
    llms_path = os.path.join(PUBLIC_DIR, "llms.txt")
    cmd = ["git", "show", "f8e3ed4:public/llms.txt"]
    base_llms = subprocess.check_output(cmd, env={"GIT_CONFIG_GLOBAL": "/dev/null"}).decode("utf-8")

    # Ensure Pomodoro article is in base knowledge hub
    pomo_entry = "- [How to Master Deep Work with a MacBook Notch Pomodoro Timer](https://notchdock.app/blog/macbook-notch-pomodoro-timer-deep-work.html): Complete guide to deep work, flow state protection, and ambient Pomodoro tracking inside the MacBook camera notch.\n"
    if "macbook-notch-pomodoro-timer-deep-work.html" not in base_llms:
        base_llms = base_llms.replace(
            "## Blog & Engineering Guides (Knowledge Hub)\n\n",
            "## Blog & Engineering Guides (Knowledge Hub)\n\n" + pomo_entry
        )

    # Organize curated entries by cluster
    cluster_names = {
        "sports-stocks": "Live Sports, Matchday & Financial Markets",
        "focus": "Deep Work, Pomodoro & Focus Protocols",
        "media": "Music, YouTube Music & Media Controls",
        "alternatives": "Direct App Comparisons & Alternatives",
        "hardware": "Hardware, Display & Multi-Monitor Engineering",
        "developer": "Developer Workflows, Privacy & Terminal Tools"
    }

    categorized_entries = {}
    for art in ALL_NEW_ARTICLES:
        cluster = art["cluster"]
        if cluster not in categorized_entries:
            categorized_entries[cluster] = []
        categorized_entries[cluster].append(
            f"- [{art['title']}](https://notchdock.app/blog/{art['slug']}.html): {art['meta_desc']}"
        )

    all_markdown_sections = f"\n\n### Comprehensive Knowledge Hub & Engineering Guides ({len(ALL_NEW_ARTICLES)} Pillar Guides)\n"
    for cl_key, cl_name in cluster_names.items():
        entries = categorized_entries.get(cl_key, [])
        if entries:
            all_markdown_sections += f"\n#### {cl_name}\n\n" + "\n".join(entries) + "\n"

    # Insert right before ## Feature & Use-Case Pages
    if "## Feature & Use-Case Pages" in base_llms:
        parts = base_llms.split("## Feature & Use-Case Pages")
        content = parts[0] + all_markdown_sections + "\n## Feature & Use-Case Pages" + parts[1]
    else:
        content = base_llms + "\n" + all_markdown_sections

    with open(llms_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Updated public/llms.txt with all {len(ALL_NEW_ARTICLES)} curated pillar guides.")

def main():
    print(f"Total curated pillar articles loaded: {len(ALL_NEW_ARTICLES)}")
    assert len(ALL_NEW_ARTICLES) == 77, f"Expected 77 articles, got {len(ALL_NEW_ARTICLES)}"

    # Check for duplicate slugs
    slugs = [a["slug"] for a in ALL_NEW_ARTICLES]
    assert len(slugs) == len(set(slugs)), "Duplicate slug detected in article dataset!"

    # Clean up orphan articles
    cleanup_orphan_articles()

    # Render each article to blog/<slug>.html
    for idx, art in enumerate(ALL_NEW_ARTICLES):
        slug = art["slug"]
        file_path = os.path.join(BLOG_DIR, f"{slug}.html")
        html_content = render_article_html(art)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        if (idx + 1) % 20 == 0 or idx == len(ALL_NEW_ARTICLES) - 1:
            print(f"Rendered {idx + 1}/{len(ALL_NEW_ARTICLES)} articles: {slug}.html")

    # Update index, sitemap, llms.txt
    update_blog_index()
    update_sitemap()
    update_llms_txt()

    # Verification checks
    html_files = [f for f in os.listdir(BLOG_DIR) if f.endswith(".html")]
    print(f"Verification: Total HTML files in blog/: {len(html_files)} (Expected: 86)")
    assert len(html_files) == 86, f"Expected 86 HTML files in blog/, found {len(html_files)}"

    print("Successfully generated and synchronized all 77 curated SEO & GEO pillar blog articles!")

if __name__ == "__main__":
    main()
