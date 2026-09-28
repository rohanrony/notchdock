#!/usr/bin/env python3
"""
NotchDock 100 SEO & GEO Blog Posts Generator
Compiles 100 high-quality blog posts across 7 clusters, updates blog/index.html,
sitemap.xml, and public/llms.txt.
"""

import os
import sys
import json
import re

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
        # Look up related articles
        for r_slug in related_slugs:
            # Match in ALL_NEW_ARTICLES or default
            target = next((a for a in ALL_NEW_ARTICLES if a["slug"] == r_slug), None)
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

def update_blog_index():
    index_path = os.path.join(BLOG_DIR, "index.html")
    with open(index_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Create cards for all 100 new articles
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

        # Category tags for client-side filter
        # e.g. sports-stocks, focus, media, notifications, alternatives, hardware, developer
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

    # Update filter pills if needed to ensure all 7 clusters exist
    updated_filter_pills = """<!-- Topic Filter Pills -->
        <div class="blog-tags-bar" id="blog-filters">
          <span class="blog-tag-pill active" data-filter="all"><i class="fa-solid fa-layer-group"></i> All Articles (108)</span>
          <span class="blog-tag-pill" data-filter="sports-stocks"><i class="fa-solid fa-trophy"></i> Sports & Market Tickers</span>
          <span class="blog-tag-pill" data-filter="focus"><i class="fa-solid fa-brain"></i> Deep Work & Focus</span>
          <span class="blog-tag-pill" data-filter="media"><i class="fa-solid fa-music"></i> Media & YouTube Music</span>
          <span class="blog-tag-pill" data-filter="alternatives"><i class="fa-solid fa-scale-balanced"></i> App Comparisons</span>
          <span class="blog-tag-pill" data-filter="hardware"><i class="fa-solid fa-desktop"></i> Hardware & Displays</span>
          <span class="blog-tag-pill" data-filter="developer"><i class="fa-solid fa-shield-halved"></i> Developer & Privacy</span>
        </div>"""

    content = re.sub(r'<!-- Topic Filter Pills -->\s*<div class="blog-tags-bar" id="blog-filters">.*?</div>', updated_filter_pills, content, flags=re.DOTALL)

    # Insert cards at end of existing grid (right before </div>\s*<!-- Call to Action Banner -->)
    insertion_marker = '<!-- Call to Action Banner -->'
    parts = content.split(insertion_marker)
    if len(parts) == 2:
        # Find the last </div> before insertion_marker
        last_div_idx = parts[0].rfind('</div>')
        new_first_part = parts[0][:last_div_idx] + cards_html + "\n        </div>\n\n        "
        content = new_first_part + insertion_marker + parts[1]

    # Update JSON-LD
    # Find blogPost array and extend
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
    print("Updated blog/index.html with 100 new cards and updated filter pills.")

def update_sitemap():
    sitemap_path = os.path.join(PUBLIC_DIR, "sitemap.xml")
    with open(sitemap_path, "r", encoding="utf-8") as f:
        content = f.read()

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
        # Ensure not already in sitemap
        if f"https://notchdock.app/blog/{slug}.html" not in content:
            new_urls += url_entry

    if new_urls:
        content = content.replace("</urlset>", new_urls + "</urlset>")
        with open(sitemap_path, "w", encoding="utf-8") as f:
            f.write(content)
        print("Updated public/sitemap.xml with 100 new blog URLs.")

def update_llms_txt():
    llms_path = os.path.join(PUBLIC_DIR, "llms.txt")
    with open(llms_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Organize entries by cluster
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

    all_markdown_sections = "\n\n### Comprehensive Knowledge Hub & Engineering Guides (100 Articles)\n"
    for cl_key, cl_name in cluster_names.items():
        entries = categorized_entries.get(cl_key, [])
        if entries:
            all_markdown_sections += f"\n#### {cl_name}\n\n" + "\n".join(entries) + "\n"

    # Insert right before ## Feature & Use-Case Pages
    if "## Feature & Use-Case Pages" in content:
        parts = content.split("## Feature & Use-Case Pages")
        content = parts[0] + all_markdown_sections + "\n## Feature & Use-Case Pages" + parts[1]
    else:
        content += "\n" + all_markdown_sections

    with open(llms_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated public/llms.txt with all 100 new categorized guides.")

def main():
    print(f"Total new articles loaded: {len(ALL_NEW_ARTICLES)}")
    assert len(ALL_NEW_ARTICLES) == 100, f"Expected 100 articles, got {len(ALL_NEW_ARTICLES)}"

    # Check for duplicate slugs
    slugs = [a["slug"] for a in ALL_NEW_ARTICLES]
    assert len(slugs) == len(set(slugs)), "Duplicate slug detected in article dataset!"

    # Render each article to blog/<slug>.html
    for idx, art in enumerate(ALL_NEW_ARTICLES):
        slug = art["slug"]
        file_path = os.path.join(BLOG_DIR, f"{slug}.html")
        html_content = render_article_html(art)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        if (idx + 1) % 20 == 0 or idx == len(ALL_NEW_ARTICLES) - 1:
            print(f"Rendered {idx + 1}/100 articles: {slug}.html")

    # Update index, sitemap, llms.txt
    update_blog_index()
    update_sitemap()
    update_llms_txt()

    print("Successfully generated all 100 SEO & GEO blog articles!")

if __name__ == "__main__":
    main()
